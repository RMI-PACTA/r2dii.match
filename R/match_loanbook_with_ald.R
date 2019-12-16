match_loanbook_with_ald <- function(x, y, ..., threshold = 0.8) {
  out <- dplyr::left_join(
    x = match_all_against_all(x, y, ...),
    y = x,
    by = c("simpler_name_x" = "simpler_name")
  )

  dplyr::filter(out, score >= threshold)
}
