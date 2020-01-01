#' Pick rows from a dataframe based on a priority set at some columns
#'
#' @param data A dataframe.
#' @param .at Most commonly, a character vector of one column name. For more
#'   general usage see the `.vars` argument to [dplyr::arrange_at()].
#' @param priority Most commonly, a character vector of the priority to
#'   re-order the column(x) given by `.at`.
#'
#' @return A dataframe, commonly with less rows than the input.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' data <- tibble::tribble(
#'   ~x, ~y,
#'   1, "a",
#'   2, "a",
#'   2, "z",
#' )
#'
#' data %>% prioritize_at("y")
#'
#' data %>%
#'   group_by(x) %>%
#'   prioritize_at("y")
#'
#' data %>%
#'   group_by(x) %>%
#'   prioritize_at(.at = "y", priority = c("z", "a")) %>%
#'   arrange(x) %>%
#'   ungroup()
prioritize_at <- function(data, .at, priority = NULL) {
  data %>%
    dplyr::arrange_at(.at, .funs = prioritize, priority = priority) %>%
    dplyr::filter(dplyr::row_number() == 1L)
}

prioritize <- function(x, priority) {
  forcats::fct_relevel(x, priority)
}
