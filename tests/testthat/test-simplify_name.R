# Based on https://github.com/2DegreesInvesting/pacta/blob/master/
#   tests/testthat/test-name-simplification.R

test_that("simplifyName with `NA` returns `NA_character`", {
  expect_equal(simplifyName(NA), NA_character_)
})

test_that("simplifyName with '' returns ''", {
  expect_equal(simplifyName(""), "")
})

test_that("simplifyName lowercases a letter", {
  expect_equal(simplifyName("A"), "a")
})

test_that("simplifyName trims a string, removes 'and', and lowercases initials", {
  expect_equal(simplifyName("A"), "a")
})

test_that("simplifyName with 'public limited company' returns 'plc'", {
  expect_equal(simplifyName("public limited company"), "plc")
})

test_that("simplify works with a vector of length > 1", {
  expect_equal(simplifyName(c("A", "B")), c("a", "b"))
})

test_that("simplifyName removes: and och en und &", {
  expect_equal(
    simplifyName(c(" and ", " och ", " en ", " und ", " & ")),
    c("", "", "", "", "")
  )
})

test_that("simplifyName removes: . , - / $", {
  expect_equal(
    simplifyName(c(" . ", " , ", " - ", " / ", " $ ")),
    c("", "", "", "", "")
  )
})

test_that("simplifyName is sensitive to `cut.ownership`", {
  expect_equal(
    simplifyName("One-Two-Three plc"),
    "onetwothree plc"
  )

  expect_equal(
    simplifyName("One-Two-Three plc", cut.ownership = TRUE),
    "onetwothree"
  )
})

# FIXME: Understand what the 3rd argument does and clarify these tests
test_that("custom reduction rules", {
  red <- data.frame(From = "AAAA", To = "BBB", stringsAsFactors = FALSE)

  expect_equal(
    simplifyName(
      "Aaa Aaaa",
      cut.ownership = FALSE,
      # FIXME: What's this?
      red
    ),
    "aaabbb"
  )
  expect_equal(
    simplifyName(
      "AAA and AAA",
      cut.ownership = FALSE,
      # FIXME: What's this?
      red
    ),
    "aaaandaaa"
  )
})

# FIXME: Understand what the 3rd and 4th argument do and clarify these tests
test_that("custom ownership types", {
  red <- data.frame(From = character(), To = character())
  own <- c("a1", "a2")
  expect_equal(simplifyName("Test a1", FALSE, red, own), "test a1")
  expect_equal(simplifyName("Test a1 a3", TRUE, red, own), "testa1a3")
})
