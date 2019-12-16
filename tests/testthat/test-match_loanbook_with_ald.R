library(dplyr)

test_that("match_loanbook_with_ald wraps match_all_against_all", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  expect_equal(
    match_all_against_all(x, y),
    match_loanbook_with_ald(x, y)
  )
})



# test_that("match_loanbook_with_ald wraps match_all_against_all", {
#   library(dplyr)
#
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
