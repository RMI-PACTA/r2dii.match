#' @export

calculate_match_success_rate <- function(matched, loanbook) {
  merge_by <-
    c(
      sector_classification_system = "code_system",
      sector_classification_direct_loantaker = "code"
    )

  loanbook_with_sectors <-
    loanbook %>%
    purrr::modify_at(names(merge_by), as.character) %>%
    dplyr::left_join(r2dii.data::sector_classifications, by = merge_by)

  by_cols <- names(matched)[names(matched) %in% names(loanbook_with_sectors)]

  dplyr::left_join(loanbook_with_sectors, matched, by = by_cols) %>%
    dplyr::mutate(
      loan_size_outstanding = as.numeric(.data$loan_size_outstanding),
      loan_size_credit_limit = as.numeric(.data$loan_size_credit_limit),
      matched = dplyr::case_when(
        score == 1   ~ "Matched",
        is.na(score) ~ "Not Matched",
        TRUE         ~ "Not Mached"
      ),
      sector = dplyr::case_when(
        borderline == TRUE & matched == "Not Matched" ~ "not in scope",
        TRUE ~ sector
      )
    )
}
