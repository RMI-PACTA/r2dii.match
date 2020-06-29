# Based on https://github.com/2DegreesInvesting/pacta/
# test-name-simplification.R
test_that("to_alias with `NA` returns `NA_character`", {
  expect_equal(to_alias(NA), NA_character_)
})

test_that("to_alias with '' returns ''", {
  expect_equal(to_alias(""), "")
})

test_that("to_alias lowercases a letter", {
  expect_equal(to_alias("A"), "a")
})

test_that("to_alias with 'public limited company' returns 'plc'", {
  expect_equal(to_alias("public limited company"), "plc")
})

test_that("simplify works with a vector of length > 1", {
  expect_equal(to_alias(c("A", "B")), c("a", "b"))
})

test_that("to_alias removes: and och en und &", {
  expect_equal(
    to_alias(c(" and ", " och ", " en ", " und ", " & ")),
    c("", "", "", "", "")
  )
})

test_that("to_alias removes: . , - / $", {
  expect_equal(
    to_alias(c(" . ", " , ", " - ", " / ", " $ ")),
    c("", "", "", "", "")
  )
})

test_that("to_alias is sensitive to `remove_ownership`", {
  expect_equal(
    to_alias("One-Two-Three plc"),
    "onetwothree plc"
  )

  expect_equal(
    to_alias("One-Two-Three plc", remove_ownership = TRUE),
    "onetwothree"
  )
})

test_that("to_alias takes lookup columns in upper/lower case", {
  upper_cols <- tibble(From = "AAAA", To = "BBB")
  expect_equal(
    to_alias(
      "Aaa Aaaa",
      from_to = upper_cols
    ),
    "aaabbb"
  )

  lower_cols <- tibble(from = "AAAA", to = "BBB")
  expect_equal(
    to_alias(
      "Aaa Aaaa",
      from_to = lower_cols
    ),
    "aaabbb"
  )
})

test_that("to_alias with custom replacement rules works ok", {
  custom_replacement <- tibble(from = "AAAA", to = "BBB")

  expect_equal(
    to_alias("Aaa Aaaa", from_to = custom_replacement),
    "aaabbb"
  )
  expect_equal(
    to_alias("AAA and AAA", from_to = custom_replacement),
    "aaaandaaa"
  )
})

test_that("to_alias with custom ownership types works ok", {
  neutral_replacement <- tibble(from = character(0), to = character(0))
  custom_ownership <- c("a1", "a2")

  expect_equal(
    to_alias(
      "Test a1",
      from_to = neutral_replacement,
      ownership = custom_ownership
    ),
    "test a1"
  )

  expect_equal(
    to_alias(
      "Test a1 a3",
      from_to = neutral_replacement,
      ownership = custom_ownership,
      remove_ownership = TRUE
    ),
    "testa1a3"
  )
})

test_that("to_alias errors with malformed `from_to`", {
  expect_error(
    class = "missing_names",
    to_alias("a", from_to = tibble(bad = "a", to = "b"))
  )

  expect_error(
    class = "missing_names",
    to_alias("a", from_to = tibble(from = "a", bad = "b"))
  )
})

test_that("from_name_to_alias outputs the expectes tibble", {
  expect_is(from_name_to_alias(), "tbl_df")
  expect_named(from_name_to_alias(), c("from", "to"))
})

# pacta_data_name_reductions ----------------------------------------------

# WARNING
# If using datapaste, replace `NA` with "" so that
#    ~From,               ~To,
#  "(pte)",                NA,
# becomes
#    ~From,               ~To,
#  "(pte)",                "",
#
# styler: off
pacta_data_name_reductions <- tibble::tribble(
                             ~From,               ~To,
                           " and ",             " & ",
                           " och ",             " & ",
                            " en ",             " & ",
                           " und ",             " & ",
                           "(pte)",                "",
                           "(pvt)",                "",
                          "(pjsc)",                "",
                     "development",             "dev",
                           "group",             "grp",
                       "financing",            "fing",
                       "financial",            "fina",
                         "finance",            "fine",
     "designated activity company",             "dac",
             "limited partnership",              "lp",
                      "generation",             "gen",
                      "investment",          "invest",
                         "limited",             "ltd",
                         "company",              "co",
                   "public ltd co",             "plc",
                   "public co ltd",             "pcl",
                     "corporation",            "corp",
                "ltd liability co",             "llc",
                            "aktg",              "ag",
                    "incorporated",             "inc",
                        "holdings",           "hldgs",
                         "holding",           "hldgs",
                   "international",            "intl",
                      "government",            "govt",
                          "berhad",             "bhd",
                          "golden",             "gld",
                       "resources",             "res",
                        "resource",             "res",
                        "shipping",             "shp",
                        "partners",             "prt",
                         "partner",             "prt",
                      "associates",           "assoc",
                       "associate",           "assoc",
                           "groep",             "grp",
                      "generation",             "gen",
                      "investment",          "invest",
                       "financial",             "fin",
                       "spolka z ",           "sp z ",
  "ograniczona odpowiedzialnoscia",              "oo",
                         "sp z oo",           "spzoo",
                        "sp z o o",           "spzoo",
               "sanayi ve ticaret",  "sanayi ticaret",
                          "sanayi",             "san",
                         "ticaret",             "tic",
                         "sirketi",             "sti",
                 "san tic ltd sti",    "santicltdsti",
              "san tic anonim sti", "santicanonimsti",
                               "1",             "one",
                               "2",             "two",
                               "3",           "three",
                               "4",            "four",
                               "5",            "five",
                               "6",             "six",
                               "7",           "seven",
                               "8",           "eight",
                               "9",            "nine",
                               "0",            "null"
)
# styler: on

test_that("from_name_to_alias() is equal to its legacy in pacta", {
  expect_equal(
    setdiff(from_name_to_alias()$from, pacta_data_name_reductions$From),
    character(0)
  )

  expect_equal(
    setdiff(pacta_data_name_reductions$From, from_name_to_alias()$from),
    character(0)
  )

  expect_equal(
    setdiff(from_name_to_alias()$to, pacta_data_name_reductions$To),
    character(0)
  )

  expect_equal(
    setdiff(pacta_data_name_reductions$To, from_name_to_alias()$to),
    character(0)
  )
})

# pacta_data_ownership_types ----------------------------------------------
# Created with datapasta::dpasta(pacta_data_ownership_types)
pacta_data_ownership_types <- c(
  "dac",
  "sas",
  "asa",
  "spa",
  "pte",
  "srl",
  "ltd",
  "plc",
  "pcl",
  "bsc",
  "sarl",
  "as",
  "nv",
  "bv",
  "cv",
  "pt",
  "sa",
  "se",
  "lp",
  "corp",
  "co",
  "llc",
  "ag",
  "ab",
  "inc",
  "hldgs",
  "intl",
  "govt",
  "bhd",
  "jsc",
  "pjsc",
  "gmbh",
  "spzoo"
)

test_that("get_ownership_type() is equal to its legacy in pacta", {
  expect_equal(
    setdiff(get_ownership_type(), pacta_data_ownership_types),
    character(0)
  )
})
