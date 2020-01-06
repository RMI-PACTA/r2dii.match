#' Add the columns `sector` and `borderline`
#'
#' This function adds two columns, `sector` and `borderline`:
#' * `sector`: `sector` gives climate-relevant sectors looked up from standard
#' sector classifications in production databases.
#' * `borderline`: Indicates if the classification is borderline or not.
#'
#' A company acts in a climate-relevant sector if it meets two conditions:
#' 1. It is classified in one of the sectors that translate 1 to 1 from a a
#' standard sector classification to a climate-relevant sector covered by the
#' PACTA analysis (e.g. utilities to power).
#' 2. It is classified in a sector that can but does not necessarily map to a
#' climate-relevant sector covered by the PACTA analysis (e.g. power
#' grid/network to Power, general mining to coal mining).
#'
#' For a list of sector classification systems see
#' [r2dii.dataraw::classification_bridge].
#'
#' @param data A loanbook dataframe.
#'
#' @family internal-ish
#'
#' @return A loanbook dataframe with additional `sector` and `borderline`
#'   columns.
#' @export
#'
#'
#' @examples
#' library(dplyr)
#' # Must be attached
#' library(r2dii.dataraw)
#'
#' out <- add_sector_and_borderline(loanbook_demo)
#' new_columns <- setdiff(names(out), names(loanbook_demo))
#'
#' out %>%
#'   select(new_columns, everything())
add_sector_and_borderline <- function(data) {
  crucial <- c(
    "sector_classification_system",
    "sector_classification_direct_loantaker"
  )
  check_crucial_names(data, crucial)

  pkg <- "package:r2dii.dataraw"
  check_is_attached(pkg)

  classification <- enlist_datasets(pkg, pattern = "_classification$") %>%
    purrr::imap(~ mutate(.x, code_system = toupper(.y))) %>%
    purrr::map(~ select(
      .,
      .data$sector, .data$borderline,
      # Required in `by` below
      .data$code, .data$code_system
    )) %>%
    # Coerce every column to character for more robust reduce() and join()
    purrr::map(~ purrr::modify(.x, as.character)) %>%
    # Collapse the list of dataframes to a single, row-bind dataframe
    purrr::reduce(dplyr::bind_rows) %>%
    purrr::modify_at("borderline", as.logical) %>%
    # Avoid duplicates
    unique() %>%
    # Reformat code_system
    mutate(code_system = gsub("_CLASSIFICATION", "", .data$code_system))

  # Coerce crucial columns to character for more robust join()
  data2 <- data %>% purrr::modify_at(crucial, as.character)

  has_unknown_code_system <-
    !any(data2$sector_classification_system %in% classification$code_system)
  if (has_unknown_code_system) {
    stop(
      "At least one loan must use 2dii's sector code system.\n",
      "Are all of your loans classified as in 2dii's database?",
      call. = FALSE
    )
  }

  by <- stats::setNames(c("code_system", "code"), crucial)
  out <- left_join(data2, classification, by = by)

  restore_typeof(data, out, crucial)
}

exported_data <- function(package) {
  utils::data(package = package)$results[, "Item"]
}

check_is_attached <- function(pkg) {
  is_attached <- any(grepl(pkg, search()))

  if (!is_attached) {
    stop(
      sprintf("%s must be attached.\nRun `library(%s)`.", pkg, pkg),
      call. = FALSE
    )
  }

  invisible(pkg)
}

enlist_datasets <- function(package, pattern) {
  datasets_name <- grep(pattern, exported_data("r2dii.dataraw"), value = TRUE)

  datasets_name %>%
    purrr::map(~ get(.x, envir = as.environment(package))) %>%
    purrr::set_names(datasets_name)
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
