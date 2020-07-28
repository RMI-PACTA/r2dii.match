#' Crucial `loanbook` columns for `match_name()`
#'
#' This is a helper to select the minimum `loanbook` columns you need to run
#' `match_name()`. Using more columns may use too much time and memory.
#'
#' @family helpers
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' crucial_lbk()
crucial_lbk <- function() {
  c(
    "id_ultimate_parent",
    "name_ultimate_parent",
    "id_direct_loantaker",
    "name_direct_loantaker",
    "sector_classification_system",
    "sector_classification_direct_loantaker"
  )
}
