library(dplyr)
library(r2dii.data)

test_that("w/ full demo datasets throws no error", {
  expect_no_error(
    loanbook_demo %>%
      slice(4:5) %>%
      match_name(ald_demo) %>%
      prioritize(priority = "ultimate_parent")
  )
})

test_that("errors gracefully if data lacks crucial columns", {
  expect_error(prioritize(fake_matched()), NA)

  expect_error(
    prioritize(select(fake_matched(), -id_loan)),
    class = "missing_names"
  )
  expect_error(
    prioritize(select(fake_matched(), -level)),
    class = "missing_names"
  )
  expect_error(
    prioritize(select(fake_matched(), -score)),
    class = "missing_names"
  )
  expect_error(
    prioritize(select(fake_matched(), -sector_ald)),
    class = "missing_names"
  )
  expect_error(
    prioritize(select(fake_matched(), -sector)),
    class = "missing_names"
  )
})

test_that("errors gracefully with bad `priority`", {
  expect_warning(
    prioritize(fake_matched(), priority = c("bad1", "bad2")),
    "[Ii]gnoring.*levels.*bad1.*bad2"
  )
})

test_that("picks score equal to 1", {
  matched <- fake_matched(score = c(1, 0.9))
  expect_equal(min(prioritize(matched)$score), 1)
})

test_that("picks the highest level per id_loan", {
  # styler: off
  id_level <- tibble::tribble(
    ~id_loan,                 ~level,
        "aa",      "ultimate_parent",
        "aa",     "direct_loantaker",  # pick this **
        "bb",  "intermediate_parent",  # pick this **
        "bb",      "ultimate_parent",
  )
  # styler: on
  matched <- fake_matched(id_loan = id_level$id_loan, level = id_level$level)

  expect_equal(
    prioritize(matched)$level,
    c("direct_loantaker", "intermediate_parent") # **
  )
})

test_that("takes a `priority` function or lambda", {
  matched <- fake_matched(level = c("direct_loantaker", "ultimate_parent"))
  out <- prioritize(matched, priority = NULL)
  expect_equal(out$level, "direct_loantaker")

  # Reverse with function
  out <- prioritize(matched, priority = rev)
  expect_equal(out$level, "ultimate_parent")

  # Reverse with lambda
  out <- prioritize(matched, priority = ~ rev(.x))
  expect_equal(out$level, "ultimate_parent")
})

test_that("is sensitive to `priority`", {
  expect_equal(
    prioritize(fake_matched(level = c("z", "a")), priority = "z")$level,
    "z"
  )
})

test_that("ignores existing groups", {
  # styler: off
  matched <- tibble::tribble(
    ~id_loan, ~other_id, ~level,
         "a",         1,    "z",  # pick **
         "a",         2,    "a",
         "b",         3,    "z",  # pick **
         "b",         4,    "a",
  ) %>%
    # Crucial columns with toy values
    mutate(sector = "coal", sector_ald = "coal", score = 1) %>%
    group_by(other_id)
  # styler: on

  expect_equal(
    prioritize(matched, priority = "z")$level,
    c("z", "z") # **
  )
})

test_that("previous preserves groups", {
  matched <- fake_matched(other_id = 1:4) %>%
    group_by(other_id, score)

  expect_equal(
    dplyr::group_vars(prioritize(matched)),
    c("other_id", "score")
  )
})

test_that("prioritize_level otputs expected vector", {
  matched <- tibble(
    level = c(
      "intermediate_parent_1",
      "direct_loantaker",
      "direct_loantaker",
      "direct_loantaker",
      "ultimate_parent",
      "intermediate_parent_2"
    )
  )
  expect_equal(
    prioritize_level(matched),
    c(
      "direct_loantaker",
      "intermediate_parent_1",
      "intermediate_parent_2",
      "ultimate_parent"
    )
  )
})

test_that("prioritize_at with ungrouped data picks the highest priority row", {
  out <- tibble(x = c("a", "z")) %>%
    prioritize_at(.at = "x", priority = c("z", "a"))

  expect_equal(out$x, "z")
})

test_that("prioritize_at with grouped data picks one row per group", {
  out <- tibble(
    x = c(1, 2, 2),
    y = c("a", "a", "z")
  ) %>%
    group_by(x) %>%
    prioritize_at(.at = "y", priority = c("z", "a")) %>%
    arrange(x)

  expect_equal(out$y, c("a", "z"))
})

test_that("does not warn if a group has not all priority items", {
  expect_no_warning(
    fake_matched(level = c("a", "z"), new = level) %>%
      group_by(new) %>%
      prioritize(priority = c("z", "a"))
  )
})

test_that("w/ id_loan at level direct* & ultimate* picks only direct* (#106)", {
  matched <- fake_matched(level = c("ultimate_parent", "direct_loantaker"))
  expect_identical(prioritize(matched)$level, "direct_loantaker")
})

test_that("output is independent from the row-order of the input (#113)", {
  # styler: off
  # Could use fake_matched() but the data is clearer this way
  matched_direct <- tibble::tribble(
  ~id_loan,   ~id_2dii,             ~level, ~score,      ~sector,  ~sector_ald,
       "A",        "D", "direct_loantaker",      1, "automotive", "automotive",
       "A",        "U",  "ultimate_parent",      1, "automotive", "automotive",
       "B",        "U",  "ultimate_parent",      1, "automotive", "automotive",
  )
  # styler: on

  matched_invert <- dplyr::arrange(matched_direct, desc(id_loan))

  testthat::expect_equal(
    prioritize(matched_direct)$id_loan,
    prioritize(matched_invert)$id_loan
  )
})

test_that("error if score=1 & values by id_loan+level are duplicated (#114)", {
  valid <- fake_matched(score = 0:1)
  expect_no_error(prioritize(valid))

  invalid <- fake_matched(score = c(1, 1))
  expect_error(
    class = "duplicated_score1_by_id_loan_by_level",
    prioritize(invalid)
  )

  verify_output(
    test_path("output", "prioritize-duplicated_score1_by_id_loan_by_level.txt"),
    prioritize(invalid)
  )
})

test_that("passes if score=1 & values by id_loan are duplicated for distinct
          levels (#122)", {
  valid <- fake_matched(
    score = 1,
    id_loan = "L1",
    level = c("direct_loantaker", "intermediate_parent", "ultimate_parent"),
    id_2dii = c("dl", "ip", "up")
  )

  expect_no_error(prioritize(valid))
})
