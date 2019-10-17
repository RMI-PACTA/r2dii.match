# Based on https://github.com/2DegreesInvesting/pacta/blob/master/
#   tests/testthat/test-name-simplification.R

test_that("replace_customer_name with `NA` returns `NA_character`", {
  expect_equal(replace_customer_name(NA), NA_character_)
})

test_that("replace_customer_name with '' returns ''", {
  expect_equal(replace_customer_name(""), "")
})

test_that("replace_customer_name lowercases a letter", {
  expect_equal(replace_customer_name("A"), "a")
})

test_that("replace_customer_name with 'public limited company' returns 'plc'", {
  expect_equal(replace_customer_name("public limited company"), "plc")
})

test_that("simplify works with a vector of length > 1", {
  expect_equal(replace_customer_name(c("A", "B")), c("a", "b"))
})

test_that("replace_customer_name removes: and och en und &", {
  expect_equal(
    replace_customer_name(c(" and ", " och ", " en ", " und ", " & ")),
    c("", "", "", "", "")
  )
})

test_that("replace_customer_name removes: . , - / $", {
  expect_equal(
    replace_customer_name(c(" . ", " , ", " - ", " / ", " $ ")),
    c("", "", "", "", "")
  )
})

test_that("replace_customer_name is sensitive to `remove_ownership`", {
  expect_equal(
    replace_customer_name("One-Two-Three plc"),
    "onetwothree plc"
  )

  expect_equal(
    replace_customer_name("One-Two-Three plc", remove_ownership = TRUE),
    "onetwothree"
  )
})

test_that("replace_customer_name takes lookup columns in upper/lower case", {
  upper_cols <- tibble::tibble(From = "AAAA", To = "BBB")
  expect_equal(
    replace_customer_name(
      "Aaa Aaaa",
      from_to = upper_cols
    ),
    "aaabbb"
  )

  lower_cols <- tibble::tibble(from = "AAAA", to = "BBB")
  expect_equal(
    replace_customer_name(
      "Aaa Aaaa",
      from_to = lower_cols
    ),
    "aaabbb"
  )
})

test_that("replace_customer_name with custom replacement rules works ok", {
  custom_replacement <- tibble::tibble(from = "AAAA", to = "BBB")

  expect_equal(
    replace_customer_name("Aaa Aaaa", from_to = custom_replacement),
    "aaabbb"
  )
  expect_equal(
    replace_customer_name("AAA and AAA", from_to = custom_replacement),
    "aaaandaaa"
  )
})

test_that("replace_customer_name with custom ownership types works ok", {
  neutral_replacement <- tibble::tibble(from = character(0), to = character(0))
  custom_ownership <- c("a1", "a2")

  expect_equal(
    replace_customer_name(
      "Test a1",
      from_to = neutral_replacement,
      ownership = custom_ownership
    ),
    "test a1"
  )

  expect_equal(
    replace_customer_name(
      "Test a1 a3",
      from_to = neutral_replacement,
      ownership = custom_ownership,
      remove_ownership = TRUE
    ),
    "testa1a3"
  )
})

test_that("get_name_replace() is equal to its legacy in pacta", {
  expect_equal(
    setdiff(get_name_replace()$from, pacta::data.name.reductions$From),
    character(0)
  )

  expect_equal(
    setdiff(pacta::data.name.reductions$From, get_name_replace()$from),
    character(0)
  )

  expect_equal(
    setdiff(get_name_replace()$to, pacta::data.name.reductions$To),
    character(0)
  )

  expect_equal(
    setdiff(pacta::data.name.reductions$To, get_name_replace()$to),
    character(0)
  )
})

test_that("get_ownership_type() is equal to its legacy in pacta", {
  expect_equal(
    setdiff(get_ownership_type(), pacta::data.ownership.types),
    character(0)
  )
})
