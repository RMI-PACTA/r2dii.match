#' Add the columns `sector` and `borderline`
#'
#' This function adds two columns, `sector` and `borderline`:
#' * `sector`: `sector` gives climate-relevant sectors looked up from standard
#' sector classifications in production databases.
#' * `borderline`: Indicates if the classification is borderline or not.
#'
#' A company acts in a climate-relevant sector if it meets two conditions:
#' 1. It is classified in one of the sectors that translate 1 to 1 from a
#' standard sector classification to a climate-relevant sector covered by the
#' PACTA analysis (e.g. utilities to power).
#' 2. It is classified in a sector that can but does not necessarily map to a
#' climate-relevant sector covered by the PACTA analysis (e.g. power
#' grid/network to Power, general mining to coal mining).
#'
#' For a list of sector classification systems see
#' [r2dii.data::sector_classifications].
#'
#' @param data A loanbook data frame.
#'
#' @return A loanbook data frame with additional `sector` and `borderline`
#'   columns.
#'
#' @examples
#' library(dplyr)
#' library(r2dii.data)
#'
#' out <- add_sector_and_borderline(r2dii.data::loanbook_demo)
#' new_columns <- setdiff(names(out), names(loanbook_demo))
#'
#' out %>%
#'   select(new_columns, everything())
#' @noRd
add_sector_and_borderline <- function(data, sector_classification = default_sector_classification()) {
  crucial <- c(
    "sector_classification_system", "sector_classification_direct_loantaker"
  )

  checked <- data %>%
    check_crucial_names(crucial) %>%
    # Coerce crucial columns to character for more robust join()
    purrr::modify_at(crucial, as.character) %>%
    check_classification(column = "sector_classification_system", classification = sector_classification) %>%
    check_classification(column = "sector_classification_direct_loantaker", classification = sector_classification)

  out <- left_join(
    checked, sector_classification,
    by = set_names(c("code_system", "code"), crucial)
  )

  restore_typeof(data, out, crucial)
}

default_sector_classification <- function() {
  r2dii.data::sector_classifications
}

check_classification <- function(data,
                                 column,
                                 # FIXME: Remove needless argument?
                                 classification = NULL) {
  # To call columns from both data and classification with the same colname
  reference <- rename_as_loanbook(classification)

  all_unknown <- !any(data[[column]] %in% reference[[column]])
  known <- unique(reference[[column]])
  if (all_unknown) {
    abort_all_sec_classif_unknown(column, known)
  }

  unknown <- setdiff(unique(data[[column]]), reference[[column]])
  some_unknown <- !identical(unknown, character(0))

  if (some_unknown) {
    warn_some_sec_classif_unknown(column, unknown)
  }

  invisible(data)
}

abort_all_sec_classif_unknown <- function(column, known) {
  cli::cli_abort(
    message = c(
      "Some values in {.col {column}} must be known, i.e. one of: {.val {known}}",
      "i" = "All of the values do not appear in the specified sector classification system.",
      "i" = "You may want to specify a different sector classification system (see {.fun r2dii.match::match_name})."
    ),
    class = "all_sec_classif_unknown"
  )
}

warn_some_sec_classif_unknown <- function(column, unknown) {
  cli::cli_warn(
    message = c(
      "Some values in {.col {column}} are unknown: {.val {unknown}}",
      "i" = "The unknown values do not appear in the specified sector classification system."
    ),
    class = "some_sec_classif_unknown"
  )

  invisible(column)
}

rename_as_loanbook <- function(classification) {
  classification %>%
    check_crucial_names(c("code_system", "code")) %>%
    dplyr::rename(
      sector_classification_system = "code_system",
      sector_classification_direct_loantaker = "code"
    )
}

restore_typeof <- function(data, out, crucial) {
  # This seems too rigid but fine for now
  crucial_has_length_2 <- identical(length(crucial), 2L)
  stopifnot(crucial_has_length_2)

  column_types <- purrr::map_chr(data[crucial], typeof)

  out1 <- as_type(out, crucial[[1]], column_types[[1]])
  out2 <- as_type(out1, crucial[[2]], column_types[[2]])
  out2
}

as_type <- function(.x, .at, type) {
  as_type <- paste0("as.", type)
  purrr::modify_at(.x, .at, .f = get(as_type))
}
