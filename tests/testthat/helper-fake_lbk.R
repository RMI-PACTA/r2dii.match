#' Minimal explicit loanbook and abcd datasets that allow overwriting values
#'
#' These functions are developer-oriented. They all call [tibble::tibble()] so
#' you can expect all the goodies that come with that.
#' * `fake_lbk()`includes non-crucal columns `id_intermediate_parent_1`, `name_intermediate_parent_1`.
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
#' @seealso [r2dii.data::loanbook_demo], [r2dii.data::abcd_demo]
#'
#'
#' @return A data frame
#'
#' @examples
#' fake_lbk()
#'
#' fake_abcd()
#'
#' fake_matched()
#'
#' fake_matched(id = c("a", "a"), sector = c("coal", "automotive"))
#'
#' # Helps invalidate values for tests
#' fake_abcd(name_company = "bad")
#'
#' # tibble() goodies:
#'
#' # Create new columns on the fly
#' fake_abcd(new = "a")
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
      sector_classification_direct_loantaker %||% "D35.11",
    ...
  )
}

#' See `fake_lbk()`
#' @noRd
fake_abcd <- function(name_company = NULL,
                     sector = NULL,
                     ...) {
  tibble::tibble(
    name_company = name_company %||% "alpine knits india pvt. limited",
    sector = sector %||% "power",
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
                         sector_abcd = NULL,
                         ...) {
  tibble::tibble(
    id_loan = id_loan %||% "L162",
    id_2dii = id_2dii %||% "UP1",
    level = level %||% "ultimate_parent",
    score = score %||% 1,
    sector = sector %||% "automotive",
    sector_abcd = sector_abcd %||% "automotive",
    ...
  )
}
