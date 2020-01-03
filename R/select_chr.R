#' Select elements from a vector using tidyselect helpers
#'
#' This function allows you to used tidyselect helpers to do with a character
#' vector what [dplyr::select()] allows you to do with the names of a dataframe.
#'
#' @param x A character vector.
#' @inheritDotParams tidyselect::starts_with
#'
#' @family internal-ish
#'
#' @return A character vector
#' @export
#'
#' @examples
#' library(dplyr)
#' library(r2dii.match)
#'
#' x <- paste0("number_", 1:15)
#' x
#'
#' # You can select elements from a caracter vector in many ways.
#' # All the tidyselect helpers that work with dplyr::selec() work here too.
#' x %>%
#'   select_chr(
#'     matches("_3"),
#'     contains("_2"),
#'     ends_with("_1"),
#'     number_4:number_6,
#'     -number_7,
#'     -8,
#'     11:9,
#'     "number_15"
#'   )
select_chr <- function(x, ...) {
  stopifnot(is.character(x))

  named <- tibble::as_tibble(purrr::set_names(as.list(unique(x))))
  names(dplyr::select(named, ...))
}
