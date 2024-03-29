#' Restructure an asset-level dataset (abcd) in preparation for fuzzy matching
#'
#' This function restructures an asset-level dataset (abcd) in preparation for
#' the fuzzy matching process. Most notably, it outputs an the `alias` column
#' from values in the `name_company` column.
#'
#' @param data A data frame. Should be an asset-level dataset.
#' @param join_id (Optional) A string giving the name of an `ID` column to
#'   preserve in the restructuring
#'
#' @seealso [r2dii.data::abcd_demo] `to_alias()`.
#'
#' @return A data frame with unique combinations of `name` + `sector`, including
#'   all IDs, and with elements already manually overwritten.
#'
#' @examples
#' restructure_abcd(r2dii.data::abcd_demo)
#' @noRd
restructure_abcd <- function(data) {
  crucial_names <- c("name_company", "sector")
  check_crucial_names(data, crucial_names)

  out <- dplyr::transmute(
    data,
    name = .data$name_company,
    sector = tolower(.data$sector)
  )

  out <- distinct(out)
  add_alias(out)
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
#' @return A data frame with unique combinations of `name` + `sector`, including
#'   all IDs, and with elements already manually overwritten.
#'
#' @examples
#' library(r2dii.data)
#'
#' lbk <- tibble::rowid_to_column(loanbook_demo)
#'
#' restructure_loanbook(lbk)
#'
#' restructure_loanbook(lbk, overwrite = overwrite_demo)
#' @noRd
restructure_loanbook <- function(data, overwrite = NULL) {
  check_prep_loanbook_overwrite(overwrite)
  check_prepare_loanbook_data(data)

  id_level <- extract_level_names(data, prefix = "id_")
  for (i in seq_along(id_level)) {
    data <- uniquify_id_column(data, id_column = id_level[i])
  }

  name_level <- extract_level_names(data, prefix = "name_")
  important_columns <- c("rowid", id_level, name_level)

  out <- may_add_sector_and_borderline(data)
  out <- select(
    out, all_of(c("rowid", important_columns, "sector", "borderline"))
  )
  out <- identify_loans_by_level(out)
  out <- identify_loans_by_name(out)
  out <- mutate(out, source = "loanbook")
  out <- select(out, all_of(c("rowid", prep_lbk_cols())))
  out <- distinct(out)
  out <- may_overwrite_name_and_sector(out, overwrite = overwrite)
  out <- add_alias(out)
  out
}

may_add_sector_and_borderline <- function(data) {
  if (lacks_borderline(data) || lacks_sector(data)) {
    abort("Must have both `sector` and `borderline`")
  }

  if (has_sector(data) & has_borderline(data)) {
    data2 <- data
  } else {
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

has_sector <- function(data) has_name(data, "sector")
has_borderline <- function(data) has_name(data, "borderline")
lacks_sector <- function(data) !has_sector(data) & has_borderline(data)
lacks_borderline <- function(data) has_sector(data) & !has_borderline(data)

add_alias <- function(data) {
  aliases <- to_alias(data[["name"]])
  mutate(data, alias = aliases)
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

  abort_has_intermediate_not_id(data)


  invisible(data)
}

abort_has_intermediate_not_id <- function(data) {
  x <- replace_prefix(extract_level_names(data, "name_"), to = "")
  y <- replace_prefix(extract_level_names(data, "id_"), to = "")
  missing_id <- setdiff(x, y)

  if (rlang::is_true(length(missing_id) > 0L)) {
    missing_columns <- paste0("id", missing_id, collapse = ", ")
    abort(
      class = "has_name_but_not_id",
      sprintf("Must have missing columns:\n %s", missing_columns)
    )
  }
}

check_prep_loanbook_overwrite <- function(overwrite) {
  if (is.null(overwrite)) {
    return(invisible(overwrite))
  }

  stopifnot(is.data.frame(overwrite))
  crucial <- grep("borderline", prep_lbk_cols(), value = TRUE, invert = TRUE)
  check_crucial_names(overwrite, crucial)

  invisible(overwrite)
}

prep_lbk_cols <- function() {
  c(
    "level",
    "id_2dii",
    "name",
    "sector",
    "source",
    "borderline"
  )
}

identify_loans_by_level <- function(data) {
  data %>%
    # https://bit.ly/avoid-cant-combine-spec-tbl-df
    as.data.frame() %>%
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
      cols = all_of_(cols),
      names_to = "level2",
      names_prefix = "name_",
      values_to = "name"
    ) %>%
    filter(.data$level == .data$level2) %>%
    mutate(level2 = NULL)
}
