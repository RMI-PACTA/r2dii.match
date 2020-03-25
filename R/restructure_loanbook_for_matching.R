#' Restructure an asset-level dataset (ald) in preparation for fuzzy matching
#'
#' This function restructures an asset-level dataset (ald) in preparation for
#' the fuzzy matching process. Most notably, it outputs an the `alias` column
#' from values in the `name_company` column.
#'
#' @param data A dataframe. Should be an asset-level dataset.
#'
#' @seealso [r2dii.data::ald_demo] `to_alias()`.
#'
#' @return A dataframe with unique combinations of `name` + `sector`, including
#'   all IDs, and with elements already manually overwritten.
#'
#' @examples
#' restructure_ald_for_matching(r2dii.data::ald_demo)
#' @noRd
restructure_ald_for_matching <- function(data) {
  data %>%
    check_crucial_names(c("name_company", "sector")) %>%
    select(name = .data$name_company, .data$sector) %>%
    distinct() %>%
    add_alias()
}

#' Restructure  loanbook dataset (lbk) in preparation for fuzzy matching
#'
#' This function restructures a loanbook dataset (lbk) in preparation for
#' the fuzzy matching process. Most notably, it outputs an the `alias` column
#' from values in the columns `name_direct_loantaker` and
#' `name_ultimate_parent`.
#'
#' @inheritParams match_name
#'
#' @seealso [r2dii.data::loanbook_description]
#'
#' @return A dataframe with unique combinations of `name` + `sector`, including
#'   all IDs, and with elements already manually overwritten.
#'
#' @examples
#' library(r2dii.data)
#'
#' lbk <- tibble::rowid_to_column(loanbook_demo)
#'
#' restructure_loanbook_for_matching(lbk)
#'
#' restructure_loanbook_for_matching(lbk, overwrite = overwrite_demo)
#' @noRd
restructure_loanbook_for_matching <- function(data, overwrite = NULL) {
  check_prepare_loanbook_overwrite(overwrite)
  check_prepare_loanbook_data(data)

  id_level <- extract_level_names(data, prefix = "id_")
  message("Uniquifying: ", paste0(id_level, collapse = ", "))
  for (i in seq_along(id_level)) {
    data <- uniquify_id_column(data, id_column = id_level[i])
  }

  name_level <- extract_level_names(data, prefix = "name_")
  important_columns <- c("rowid", id_level, name_level)

  data %>%
    may_add_sector_and_borderline() %>%
    select(
      .data$rowid,
      important_columns,
      .data$sector
    ) %>%
    identify_loans_by_level() %>%
    identify_loans_by_name() %>%
    mutate(source = "loanbook") %>%
    select(.data$rowid, output_cols_for_prepare_loanbook()) %>%
    distinct() %>%
    may_overwrite_name_and_sector(overwrite = overwrite) %>%
    add_alias()
}

may_add_sector_and_borderline <- function(data) {
  if (already_has_sector_and_borderline(data)) {
    rlang::warn("Using existing columns `sector` and `borderline`.")
    data2 <- data
  } else {
    message("Adding new columns `sector` and `borderline`.")
    data2 <- add_sector_and_borderline(data)
  }

  data2
}

may_overwrite_name_and_sector <- function(data, overwrite) {
  if (is.null(overwrite)) {
    return(data)
  }

  warn(
    message = glue(
      "You should only overwrite a sector at the level of the 'direct
      loantaker' (DL). If you overwrite a sector at the level of the 'ultimate
      parent' (UP) you consequently overwrite all children of that sector,
      which most likely is a mistake."
    ),
    class = "overwrite_warning"
  )

  overwrite_name_and_sector(data, overwrite = overwrite)
}

overwrite_name_and_sector <- function(data, overwrite) {
  data %>%
    left_join(overwrite, by = c("id_2dii", "level")) %>%
    mutate(
      source = if_else(is.na(.data$source.y), .data$source.x, "manual"),
      sector = if_else(is.na(.data$sector.y), .data$sector.x, .data$sector.y),
      name = if_else(is.na(.data$name.y), .data$name.x, .data$name.y)
    ) %>%
    select(names(data))
}

already_has_sector_and_borderline <- function(data) {
  has_name(data, "sector") & has_name(data, "borderline")
}

add_alias <- function(data) {
  mutate(data, alias = to_alias(.data$name))
}

check_prepare_loanbook_data <- function(data) {
  stopifnot(is.data.frame(data))

  # The "intermediate" level isn't crucial; it may be missing in some datasets
  crucial <- c(
    "rowid",
    "id_direct_loantaker",
    "name_direct_loantaker",
    "id_ultimate_parent",
    "name_ultimate_parent"
  )
  check_crucial_names(data, crucial)

  abort_if_has_intermediate_name_but_not_id(data)


  invisible(data)
}

abort_if_has_intermediate_name_but_not_id <- function(data) {
  missing_id <- setdiff(
    sort(replace_prefix(extract_level_names(data, "name_"), to = "")),
    sort(replace_prefix(extract_level_names(data, "id_"), to = ""))
  )

  if (rlang::is_true(length(missing_id) > 0L)) {
    missing_columns <- paste0("id", missing_id, collapse = ", ")
    abort(
      class = "has_name_but_not_id",
      glue("Must have missing columns:\n {missing_columns}")
    )
  }
}

check_prepare_loanbook_overwrite <- function(overwrite) {
  if (is.null(overwrite)) {
    return(invisible(overwrite))
  }

  stopifnot(is.data.frame(overwrite))
  check_crucial_names(overwrite, output_cols_for_prepare_loanbook())

  invisible(overwrite)
}

output_cols_for_prepare_loanbook <- function() {
  c(
    "level",
    "id_2dii",
    "name",
    "sector",
    "source"
  )
}

identify_loans_by_level <- function(data) {
  data %>%
    tidyr::pivot_longer(
      cols = tidyselect::starts_with("id_"),
      names_to = "level",
      names_prefix = "id_",
      values_to = "id_2dii"
    )
}

identify_loans_by_name <- function(data) {
  cols <- extract_level_names(data, prefix = "name_")

  data %>%
    purrr::modify_at(cols, as.character) %>%
    tidyr::pivot_longer(
      cols = cols,
      names_to = "level2",
      names_prefix = "name_",
      values_to = "name"
    ) %>%
    filter(.data$level == .data$level2) %>%
    mutate(level2 = NULL)
}
