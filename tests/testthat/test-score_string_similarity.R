test_that("with clearly extreeme cases returns 0 or 1", {
  expect_equal(score_string_similarity("aa", "aa"), 1L)
  expect_equal(score_string_similarity("aa", "bb"), 0L)
})

test_that("cares not for the order of the string-elements", {
  expect_true(
    identical(
      score_string_similarity("ab", "ac"),
      score_string_similarity("ac", "ab")
    )
  )
})

test_that("output is as long as its longer input", {
  out <- score_string_similarity(
    c("long", "vector"),
    "short"
  )
  expect_length(out, 2L)

  out <- score_string_similarity(
    "short",
    c("long", "vector")
  )
  expect_length(out, 2L)
})

test_that("string_similariry is sensitive to `method`", {
  method_osa <- score_string_similarity("abc", "acb", method = "osa")
  method_default <- score_string_similarity("abc", "acb")
  expect_false(identical(method_osa, method_default))
})

test_that("string_similariry is sensitive to `p`", {
  p_default <- score_string_similarity("abc", "acb")
  p_custom <- score_string_similarity("abc", "acb", p = 0.25)
  expect_false(identical(p_custom, p_default))
})

test_that("string_similariry errors with misspelled `method`", {
  expect_error(score_string_similarity("a", "a", method = "jw"), NA)

  # Not checking `class` because it caused unexpected error on TravisCI when
  # R version was other than release and oldrel
  expect_error(score_string_similarity("a", "a", metod = "jw"))
})
