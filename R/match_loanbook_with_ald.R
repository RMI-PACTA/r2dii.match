match_loanbook_with_ald <- function(x, y, ...) {
  out <- match_all_against_all(x, y, ...)
  dplyr::left_join(
    x = out, y = x,
    by = c("simpler_name_x" = "simpler_name")
  )

}
