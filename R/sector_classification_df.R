sector_classification_df <- function() {
  pkg <- "package:r2dii.dataraw"
  check_is_attached(pkg)

  pkg %>%
    enlist_datasets(pattern = "_classification$") %>%
    purrr::imap(~ mutate(.x, code_system = toupper(.y))) %>%
    purrr::map(
      select,
      .data$sector, .data$borderline, .data$code, .data$code_system
    ) %>%
    # Coerce every column to character for more robust reduce() and join()
    purrr::map(~ purrr::modify(.x, as.character)) %>%
    # Collapse the list of dataframes to a single, row-bind dataframe
    purrr::reduce(dplyr::bind_rows) %>%
    purrr::modify_at("borderline", as.logical) %>%
    # Avoid duplicates
    unique() %>%
    # Reformat code_system
    mutate(code_system = gsub("_CLASSIFICATION", "", .data$code_system))
}

check_is_attached <- function(pkg) {
  is_attached <- any(grepl(pkg, search()))

  if (!is_attached) {
    package <- sub("package:", "", pkg)
    abort(glue("{package} must be attached.\nRun `library({package})`."))
  }

  invisible(pkg)
}

enlist_datasets <- function(package, pattern) {
  datasets_name <- grep(pattern, exported_data("r2dii.dataraw"), value = TRUE)

  datasets_name %>%
    purrr::map(~ get(.x, envir = as.environment(package))) %>%
    purrr::set_names(datasets_name)
}

exported_data <- function(package) {
  utils::data(package = package)$results[, "Item"]
}
