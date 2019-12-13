#' Prepare loanbook and asset level data (ald) for matching
#'
#' These functions take all unique `name` + `sector` combinations of a loanbook
#' or asset level data, preparing it for the fuzzy matching process.
#'
#' @param data A dataframe. Should be a loanbook or asset level dataset.
#' @param overwrite A dataframe used to overwrite the sector and/or name of a
#'   particular direct loantaker or ultimate parent. If only name (sector)
#'   should be overwritten leave sector (name) as `NA`.
#'
#' @family user-oriented
#' @seealso [r2dii.dataraw::loanbook_description], [r2dii.dataraw::ald_demo].
#'
#' @return A dataframe of all unique name + sector combinations, including all
#'   IDs, and with elements already manually overwritten.
#' @export
#'
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' loanbook_demo %>%
#'   prepare_loanbook_for_matching()
#'
#' loanbook_demo %>%
#'   prepare_loanbook_for_matching(overwrite = overwrite_demo)
#'
#' ald_demo %>%
#'   prepare_ald_for_matching()
prepare_ald_for_matching <- function(data) {
  data %>%
    check_crucial_names(c("name_company", "sector")) %>%
    select(name = .data$name_company, .data$sector) %>%
    dplyr::distinct() %>%
    add_simpler_name()
}

#' @rdname prepare_ald_for_matching
#' @export
prepare_loanbook_for_matching <- function(data, overwrite = NULL) {
  # Before potentially expensive computation
  check_prepare_loanbook_overwrite(overwrite)

  check_prepare_loanbook_data(data)

  out <-   data %>%
    may_add_sector_and_borderline() %>%
    select(get_prepare_loanbook_input_columns(), .data$sector) %>%
    identify_loans_by_sector_and_level() %>%
    identify_loans_by_name_and_source() %>%
    select(get_prepare_loanbook_output_columns()) %>%
    dplyr::distinct()

  if (!is.null(overwrite)) {
    out <- out %>%
      overwrite_name_sector(overwrite = overwrite)
  }

  add_simpler_name(out)
}

may_add_sector_and_borderline <- function(data) {
  if (already_has_sector_and_borderline(data)) {
    warning("Using existing columns `sector` and `borderline`.", call. = FALSE)
    data2 <- data
  } else {
    message("Adding new columns `sector` and `borderline`.")
    data2 <- bridge_sector(data)
  }
}

already_has_sector_and_borderline <- function(data) {
  has_name(data, "sector") & has_name(data, "borderline")
}

add_simpler_name <- function(data) {
  mutate(data, simpler_name = replace_customer_name(.data$name))
}

check_prepare_loanbook_data <- function(data) {
  stopifnot(is.data.frame(data))
  check_crucial_names(data, get_prepare_loanbook_input_columns())
  invisible(data)
}

get_prepare_loanbook_input_columns <- function() {
  c(
    "id_direct_loantaker",
    "name_direct_loantaker",
    "id_ultimate_parent",
    "name_ultimate_parent"
  )
}

check_prepare_loanbook_overwrite <- function(overwrite) {
  if (is.null(overwrite)) {
    return(invisible(overwrite))
  }

  stopifnot(is.data.frame(overwrite))
  check_crucial_names(overwrite, get_prepare_loanbook_output_columns())

  invisible(overwrite)
}

get_prepare_loanbook_output_columns <- function() {
  c(
    "level",
    "id",
    "name",
    "sector",
    "source"
  )
}

identify_loans_by_sector_and_level <- function(data) {
  data %>%
    tidyr::pivot_longer(
      cols = tidyr::starts_with("id_"),
      names_to = "level",
      names_prefix = "id_",
      values_to = "id"
    )
}

identify_loans_by_name_and_source <- function(data) {
  data %>%
    mutate(
      name = if_else(
        .data$level == "direct_loantaker",
        .data$name_direct_loantaker,
        NA_character_
      ),
      name = if_else(
        .data$level == "ultimate_parent",
        .data$name_ultimate_parent,
        .data$name
      ),
      source = "loanbook"
    )
}

overwrite_name_sector <- function(data, overwrite) {
  data %>%
    dplyr::left_join(overwrite, by = c("id", "level")) %>%
    mutate(
      source = if_else(is.na(.data$source.y), .data$source.x, "manual"),
      sector = if_else(is.na(.data$sector.y), .data$sector.x, .data$sector.y),
      name = if_else(is.na(.data$name.y), .data$name.x, .data$name.y)
    ) %>%
    select(names(data))
}
