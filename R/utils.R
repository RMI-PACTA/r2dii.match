#' Check if a named object contains expected names
#'
#' It is based on:
#' https://www.rdocumentation.org/packages/fgeo.tool/versions/1.2.5/topics/check_crucial_names
#'
#' @param x A named object.
#' @param expected_names String; expected names of `x`.
#'
#' @return Invisible `x`, or an error with informative message.
#'
#' @examples
#' v <- c(name_a = 1)
#' check_crucial_names(v, "name_a")
#' try(check_crucial_names(v, "name_b"))
#'
#' df <- data.frame(name_a = 1)
#' check_crucial_names(df, "name_a")
#' try(check_crucial_names(df, "name_b"))
#' @noRd
check_crucial_names <- function(x, expected_names) {
  stopifnot(rlang::is_named(x))
  stopifnot(is.character(expected_names))

  ok <- all(expected_names %in% names(x))
  if (ok) {
    return(invisible(x))
  }

  rlang::abort(glue::glue(
    "The data must have all expected names:
    Actual: {usethis::ui_field(sort(names(x)))}
    Expected: {usethis::ui_field(sort(expected_names))}"
  ))
}
