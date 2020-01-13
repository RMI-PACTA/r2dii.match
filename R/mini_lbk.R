#' Help to create minimal loanbook data
#'
#' This function helps to create a minimal loanbook and ald datasets:
#' * `mini_lbk()` allows you to focus on a particular slice of rows and, by
#' default, focuses on the crucial columns for `match_name()`.
#' * `mini_ald()` allows you to reverse-engineer the minimum piece of ald data
#' you need to get the output of `match_name()` with a given loanbook data.
#'
#' You can transform the output of these functions into an explicit, text-based
#' dataframe by piping the output of this function to functions such as
#' [dput()], `datapaste::df_paste()`, or `datapasta::tribble_paste()`.
#'
#' @param loanbook A loanbook dataframe.
#' @param ... The slice of rows you want. Passes to [dplyr::slice()]
#' @param vars A vector of column names to select from loanbook. Defaults to the
#'   crucial columns for `match_name()`.
#' @param alias_ald A dataframe like `ald_demo` with the additional column
#'   `alias_ald`. By default this is calculated on the fly. But the process may
#'   be a little time consuming, so you may want to store the value of
#'   `alias_ald()` and reuse it later multiple times (avoiding re-calculating
#'   it each time).
#'
#' @return A dataframe.
#'
#' @seealso [dput()], `datapaste::df_paste()`, `datapasta::tribble_paste()`.
#'
#' @examples
#' mini_lbk(loanbook_demo, 1)
#' @noRd
mini_lbk <- function(loanbook, ..., vars = crucial_lbk()) {
  loanbook %>%
    dplyr::slice(...) %>%
    dplyr::select(vars, tidyselect::matches("intermediate"))
}

#' See mini_lbk
#'
#' @examples
#' loanbook_demo %>%
#'   mini_lbk(1) %>%
#'   mini_ald()
#' @noRd
mini_ald <- function(loanbook, alias_ald = NULL) {
  alias_ald <- alias_ald %||% alias_ald()
  alias_ald %>%
    filter(.data$alias_ald %in% pull_alias_ald(loanbook, .))
}

#' A dataframe identical to `ald_demo` with the additional column `alias_ald`
#' @noRd
alias_ald <- function() {
  r2dii.dataraw::ald_demo %>%
    dplyr::select(crucial_ald()) %>%
    dplyr::mutate(alias_ald = to_alias(.data$name_company)) %>%
    unique()
}

pull_alias_ald <- function(loanbook, ald) {
  loanbook %>%
    match_name(ald) %>%
    dplyr::select(dplyr::ends_with("ald")) %>%
    dplyr::pull(.data$alias_ald)
}

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

crucial_ald <- function() {
  c("name_company", "sector")
}
