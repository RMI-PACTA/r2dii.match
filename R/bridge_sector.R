#' Bridge classification between portfolio's system and 2dii's standard
#'
#' This function adds two columns, `sector` and `borderline` to the input
#' portfolio, corresponding to the bridged sector classification.
#'
#' The r2dii.dataraw package must be attached (i.e. run `library(r2dii.dataraw)`
#' before you call `bridge_sector()`).
#'
#' @param data A loanbook dataframe.
#'
#' @family functions to prepare data for matching.
#'
#' @return A loanbook dataframe with additional `sector` and `borderline`
#'   columns.
#' @export
#'
#' @examples
#' # Must be attached
#' library(r2dii.dataraw)
#'
#' bridge_sector(r2dii.dataraw::loanbook_demo)
bridge_sector <- function(data) {
  crucial <- c(
    "sector_classification_system",
    "sector_classification_direct_loantaker"
  )
  check_crucial_names(data, crucial)

  pkg <- "package:r2dii.dataraw"
  check_is_attached(pkg)

  classification <- enlist_datasets(pkg, pattern = "_classification$") %>%
    purrr::imap(~ dplyr::mutate(.x, code_system = toupper(.y))) %>%
    purrr::map(~ dplyr::select(
      .,
      # Documented  in @return (by @jdhoffa)
      .data$sector, .data$borderline,
      # Required in `by` below
      .data$code, .data$code_system
    )) %>%
    # Coerce every column to character for more robust reduce() and join()
    purrr::map(~ purrr::modify(.x, as.character)) %>%
    # Collapse the list of dataframes to a single, row-bind dataframe
    purrr::reduce(dplyr::bind_rows) %>%
    # Avoid duplicates
    unique() %>%
    # Reformat code_system
    dplyr::mutate(code_system = gsub("_CLASSIFICATION", "", .data$code_system))

  # Coerce crucial columns to character for more robust join()
  data2 <- data %>% purrr::modify_at(crucial, as.character)

  has_unknown_code_system <-
    !any(data2$sector_classification_system %in% classification$code_system)
  if (has_unknown_code_system) {
    stop(
      "At least one loan must use 2dfii's sector code system.\n",
      "Are all of your loans classified as in 2dii's database?",
      call. = FALSE
    )
  }

  by <- rlang::set_names(c("code_system", "code"), crucial)
  out <- dplyr::left_join(data2, classification, by = by)

  restore_typeof(data, out, crucial)
}

exported_data <- function(package) {
  utils::data(package = package)$results[, "Item"]
}

check_is_attached <- function(package) {
  is_attached <- any(grepl(package, search()))
  if (!is_attached) {
    code <- ui_code(glue("library({package})"))
    abort(
      glue(
        "{package} must be attached.
        Run {code}."
      )
    )
  }

  invisible(package)
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
