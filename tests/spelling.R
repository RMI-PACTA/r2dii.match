if (requireNamespace("spelling", quietly = TRUE)) {
  try(spelling::spell_check_test(
    vignettes = TRUE,
    error = FALSE,
    skip_on_cran = TRUE
  ))
}
