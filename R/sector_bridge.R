#' Bridge classification between portfolio's system and 2dii's standard
#'
#' This function adds two columns, `sector` and `borderline` to the input
#' portfolio, corresponding to the bridged sector classification.
#'
#' @param data A loanbook dataframe.
#'
#' @return A loanbook dataframe with additional `sector` and `borderline`
#'   columns.
#' @export
#'
#' @examples
#' # Must be attached
#' library(r2dii.dataraw)
#'
#' sector_bridge(r2dii.dataraw::loanbook_demo)
sector_bridge <- function(data) {

  # check that crucial columns are present in input data
  crucial_in_data <- c(
    "sector_classification_system",
    "sector_classification_direct_loantaker"
  )

  crucial_in_classification <- c(
    "code", "code_system", "sector", "borderline"
  )

  pkg <- "package:r2dii.dataraw"
  is_attached <- any(grepl(pkg, search()))
  if (!is_attached) {
    rlang::abort(glue::glue(
      "r2dii.dataraw must be attached.
      Run `library(r2dii.dataraw)`."
    ))
  }

  data_classification_names <- grep(
    pattern = "_classification$",
    x = exported_data("r2dii.dataraw"),
    value = TRUE
  )

  data_classification <- data_classification_names %>%
    purrr::map(~get(.x, envir = as.environment(pkg))) %>%
    purrr::set_names(data_classification_names)

  full_classification <- data_classification %>%
    purrr::imap(~dplyr::mutate(.x, code_system = toupper(.y))) %>%
    purrr::map(~dplyr::select(.,
      # Documented  in @return (by @jdhoffa)
      .data$sector, .data$borderline,
      # Required in `by` below
      .data$code, .data$code_system
    )) %>%
    # Coherce every column to character for more robust reduce() and join()
    purrr::map(~purrr::modify(.x, as.character)) %>%
    # Collapse the list of dataframes to a single, row-bind dataframe
    purrr::reduce(dplyr::bind_rows) %>%
    # Avoid duplicates
    unique()

  data2 <- data %>%
    # Coherce every column to character for more robust join()
    purrr::modify_at(
      c(
        "sector_classification_system",
        "sector_classification_direct_loantaker"
      ),
      as.character
    )

    dplyr::left_join(
      data2, full_classification,
      by = c(
        "sector_classification_system" = "code_system",
        "sector_classification_direct_loantaker" = "code"
      )
    )
}

exported_data <- function(package) {
  utils::data(package = package)$results[, "Item"]
}
