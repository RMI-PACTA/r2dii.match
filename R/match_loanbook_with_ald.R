match_loanbook_with_ald <- function(x,
                                    y,
                                    ...,
                                    by_sector = TRUE,
                                    threshold = 0.8,
                                    method = "jw",
                                    p = 0.1) {
  out <- dplyr::left_join(
    x = match_all_against_all(x, y, ...),
    y = x,
    by = c("simpler_name_x" = "simpler_name")
  )

  dplyr::filter(out, score >= threshold)
}
