#' Minimal explicit loanbook and ald datasets that allow overwriting values
#'
#' These funtions are developer-oriented. They all call [tibble::tibble()] so
#' you can expect all the goodies that come with that.
#' * `fake_lbk()` is based on `mini_lbk(loanbook_demo, 1)` with the additional,
#' non-crucal columns `id_intermediate_parent_1`, `name_intermediate_parent_1`.
#' * `fake_lbk()` is created from applying `mini_lbk()` to `fake_lbk()`.
#' * `fake_matched()` fakes the ouput of `match_name()`. It is based on
#' `loanbook_demo %>% filter(id_loan == "L162")`.
#'
#' @section Params
#' The arguments are the column names of the datasets being faked. They all have
#' a default and it can be overwritten.
#'
#' @section Pros and cons
#' These functions help you to avoid duplicating test code, and help
#' the reader of your code to focus on the one thing you want to test, instead
#' of burring that thing in the much longer code you need to create a fake
#' object from scratch.
#'
#' But `fake_*()` functions hide the explicit content. If the reader of your
#' code wants to inspect the data being tested, they need to jump to the
#' function definition or call them interactively.
#'
#' @seealso `mini_lbk()`, `mini_ald()`, [r2dii.data::loanbook_demo]
#'   [r2dii.data::ald_demo]
#'
#'
#' @return A data frame
#'
#' @examples
#' fake_lbk()
#'
#' fake_ald()
#'
#' fake_matched()
#'
#' fake_matched(id = c("a", "a"), sector = c("coal", "automotive"))
#'
#' identical(fake_ald(), mini_ald(fake_lbk()))
#'
#' # Helps invalidate values for tests
#' fake_ald(name_company = "bad")
#'
#' # tibble() goodies:
#'
#' # Create new columns on the fly
#' fake_ald(new = "a")
#'
#' # Support for trailing commas
#' fake_matched(id = "a", )
#' @noRd
fake_lbk <- function(sector_classification_system = NULL,
                     id_ultimate_parent = NULL,
                     name_ultimate_parent = NULL,
                     id_direct_loantaker = NULL,
                     name_direct_loantaker = NULL,
                     sector_classification_direct_loantaker = NULL,
                     ...) {
  tibble::tibble(
    sector_classification_system = sector_classification_system %||% "NACE",
    id_ultimate_parent = id_ultimate_parent %||% "UP15",
    name_ultimate_parent =
      name_ultimate_parent %||% "Alpine Knits India Pvt. Limited",
    id_direct_loantaker = id_direct_loantaker %||% "C294",
    name_direct_loantaker =
      name_direct_loantaker %||% "Yuamen Xinneng Thermal Power Co Ltd",
    sector_classification_direct_loantaker =
      sector_classification_direct_loantaker %||% 3511,
    ...
  )
}

#' See `fake_lbk()`
#' @noRd
fake_ald <- function(name_company = NULL,
                     sector = NULL,
                     alias_ald = NULL,
                     ...) {
  tibble::tibble(
    name_company = name_company %||% "alpine knits india pvt. limited",
    sector = sector %||% "power",
    alias_ald = alias_ald %||% "alpineknitsindiapvt ltd",
    ...
  )
}

#' See `fake_lbk()`
#' @noRd
fake_matched <- function(id_loan = NULL,
                         id_2dii = NULL,
                         level = NULL,
                         score = NULL,
                         sector = NULL,
                         sector_ald = NULL,
                         ...) {
  tibble::tibble(
    id_loan = id_loan %||% "L162",
    id_2dii = id_2dii %||% "UP1",
    level = level %||% "ultimate_parent",
    score = score %||% 1,
    sector = sector %||% "automotive",
    sector_ald = sector_ald %||% "automotive",
    ...
  )
}

#' Help to create minimal loanbook (lbk) and asset-level data (ald)
#'
#' These functions are developer-oriented. They help you create minimal loanbook
#' and ald datasets:
#' * `mini_lbk()` allows you to focus on a particular slice of rows and, by
#' default, focuses on the crucial columns for `match_name()`.
#' * `mini_ald()` allows you to reverse-engineer the minimum piece of ald data
#' you need to get the output of `match_name()` with a given loanbook data.
#'
#' You may transform the output of these functions into an explicit, text-based
#' data frame by piping the output of this function to functions such as
#' [dput()], `datapaste::df_paste()`, or `datapasta::tribble_paste()`.
#'
#' @param loanbook A loanbook data frame.
#' @param ... The slice of rows you want. Passed to [dplyr::slice()]
#' @param vars A vector of column names to select from loanbook. Defaults to the
#'   crucial columns for `match_name()`.
#' @param alias_ald A data frame like `ald_demo` with the additional column
#'   `alias_ald`. By default this is calculated on the fly. But the process may
#'   be a little time consuming, so you may want to store the value of
#'   `alias_ald()` and reuse it later multiple times (avoiding re-calculating
#'   it each time).
#'
#' @return A data frame.
#'
#' @seealso [dput()], `datapaste::df_paste()`, `datapasta::tribble_paste()`.
#'
#' @examples
#' mini_lbk(loanbook_demo, 1)
#'
#' loanbook_demo %>%
#'   mini_lbk(1) %>%
#'   mini_ald()
#' @noRd
mini_lbk <- function(loanbook, ..., vars = crucial_lbk()) {
  loanbook %>%
    slice(...) %>%
    select(vars, tidyselect::matches("intermediate"))
}

#' See `mini_lbk()`
#' @noRd
mini_ald <- function(loanbook, alias_ald = NULL) {
  alias_ald <- alias_ald %||% alias_ald()
  alias_ald %>%
    filter(.data$alias_ald %in% pull_alias_ald(loanbook, .))
}

#' A data frame identical to `ald_demo` with the additional column `alias_ald`
#' @noRd
alias_ald <- function() {
  r2dii.data::ald_demo %>%
    select(crucial_ald()) %>%
    mutate(alias_ald = to_alias(.data$name_company)) %>%
    distinct()
}

pull_alias_ald <- function(loanbook, ald) {
  loanbook %>%
    match_name(ald) %>%
    select(dplyr::ends_with("ald")) %>%
    pull(.data$alias_ald)
}
