#' Select elements from a vector using tidyselect helpers
#'
#' This function allows you to select elements of a character vector like
#' [dplyr::select()] allows you to select columns of a data frame -- via
#' tidyselect helpers.
#'
#' @param x A character vector.
#' @inheritDotParams tidyselect::starts_with
#'
#' @return A character vector
#'
#' @examples
#' # Access tidyselect helpers via dplyr or directly with `library(tidyselect)`
#' library(dplyr)
#'
#' x <- paste0("number_", 1:15)
#' x
#'
#' # You can select elements from a caracter vector in many ways. All the
#' # tidyselect helpers that work with dplyr::selec() work here too.
#' select_chr(
#'   x,
#'   matches("_3"),
#'   contains("_2"),
#'   ends_with("_1"),
#'   number_4:number_6,
#'   -number_7,
#'   -8,
#'   11:9,
#'   "number_15"
#' )
#' @noRd
select_chr <- function(x, ...) {
  stopifnot(is.character(x))

  x_df <- as_tibble(purrr::set_names(as.list(unique(x))))
  names(dplyr::select(x_df, ...))
}
