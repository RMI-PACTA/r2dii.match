#' Select elements from a vector using tidyselect helpers
#'
#' This function allows you to used tidyselect helpers to do with a character
#' vector what [dplyr::select()] allows you to do with the names of a dataframe.
#'
#' @param x A character vector.
#' @inheritDotParams tidyselect::starts_with
#'
#' @return A character vector
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' # With dplyr::select() you can do something like this to a dataframe
#' mtcars %>%
#'   select(starts_with("cy"), matches("arb"), everything())
#'
#' # With select_chr() you can do the same to a character vector
#' a_character_vector <- mtcars %>%
#'   names()
#'
#' a_character_vector %>%
#'   select_chr(starts_with("cy"), matches("arb"), everything())
#'
#' # Like select(), you may use "quoted" strings, bare strings, and positions
#' a_character_vector %>%
#'   select_chr("drat", cyl, 4:6)
select_chr <- function(x, ...) {
  stopifnot(is.character(x))

  named <- tibble::as_tibble(purrr::set_names(as.list(unique(x))))
  names(dplyr::select(named, ...))
}
