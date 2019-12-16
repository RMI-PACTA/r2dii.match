library(dplyr)

test_that("match_loanbook_with_ald recovers `sector`", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  expect_true(
    rlang::has_name(match_loanbook_with_ald(x, y), "sector")
  )
})

test_that("match_loanbook_with_ald takes `threshold`", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  expect_error(
    match_loanbook_with_ald(x, y, threshold = 0.5),
    NA
  )
})

test_that("match_loanbook_with_ald takes `by_sector`", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  out1 <- match_all_against_all(x, y, by_sector = TRUE)
  out2<- match_all_against_all(x, y, by_sector = FALSE)
  expect_false(identical(out1, out2))
})
#
# test_that("match_loanbook_with_ald recovers `sector`", {
#   x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
#   y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))
#
#   out <- match_all_against_all(x, y, by_sector = FALSE)
#   out
#
#   # Recover sectors from x & y
#   left_join(out, x, by = c("simpler_name_x" = "simpler_name")) %>%
#     dplyr::rename(sector_x = sector) %>%
#     left_join(y, by = c("simpler_name_y" = "simpler_name")) %>%
#     dplyr::rename(sector_y = sector)
#
# })
# test_that("match_loanbook_with_ald recovers `sector`", {
#   x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
#   y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))
#
#   out <- match_all_against_all(x, y)
#
#   # Recover sector
#   left_join(out, x, by = c("simpler_name_x" = "simpler_name"))
#
#   threshold <- 0.5
#   match_all_against_all(x, y) %>%
#     dplyr::filter(score >= threshold)
#
#   out <- match_all_against_all(x, y, by_sector = FALSE)
#   out
#
#   # Recover sectors from x & y
#   left_join(out, x, by = c("simpler_name_x" = "simpler_name")) %>%
#     dplyr::rename(sector_x = sector) %>%
#     left_join(y, by = c("simpler_name_y" = "simpler_name")) %>%
#     dplyr::rename(sector_y = sector)
#
# })
