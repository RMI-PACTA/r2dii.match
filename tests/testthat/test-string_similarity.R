test_that("string_similarity with clearly extreeme cases returns 0 or 1", {
  expect_equal(string_similarity("aa", "aa"), 1L)
  expect_equal(string_similarity("aa", "bb"), 0L)
})

test_that("string_similarity cares not for the order of the string-elements", {
  expect_true(
    identical(
      string_similarity("ab", "ac"),
      string_similarity("ac", "ab")
    )
  )
})

test_that("string_similarity output is as long as its longer input", {
  out <- string_similarity(
    c("long", "vector"),
    "short"
  )
  expect_length(out, 2L)

  out <- string_similarity(
    "short",
    c("long", "vector")
  )
  expect_length(out, 2L)
})

test_that("string_similariry is sensitive to `method`", {
  method_osa <- string_similarity("abc", "acb", method = "osa")
  method_default <- string_similarity("abc", "acb")
  expect_false(identical(method_osa, method_default))
})

test_that("string_similariry is sensitive to `p`", {
  p_default <- string_similarity("abc", "acb")
  p_custom <- string_similarity("abc", "acb", p = 0.25)
  expect_false(identical(p_custom, p_default))
})

test_that("string_similariry passes arguments to stringdist via `...`", {
  x <- y <- letters[1:10]
  default <- string_similarity(x, y)

  weight <- seq(0.1, 0.3, by = 0.1)
  custom_weight <- string_similarity(x, y, weight = weight)
  expect_false(identical(default, custom_weight))
})

test_that("string_similariry errors with misspelled argument passed to `...`", {
  x <- y <- letters[1:10]
  weights <- seq(0.1, 0.3, by = 0.1)

  expect_error(
    string_similarity(x, y, method = "jw", p = 0.1, weight = weights),
    NA
  )

  # Not checking `class` because it caused unexpected error on TravisCI when
  # R version was other than release and oldrel
  expect_error(
    string_similarity(x, y, method = "jw", p = 0.1, weigth = weights)
  )
})

test_that("string_similariry errors with misspelled `method`", {
  expect_error(string_similarity("a", "a", method = "jw"), NA)

  # Not checking `class` because it caused unexpected error on TravisCI when
  # R version was other than release and oldrel
  expect_error(string_similarity("a", "a", metod = "jw"))
})
