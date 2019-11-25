#' Run matching between two lists
#'
#' Applies the string_similarity function to every combination of two lists:
#' `names_to_match` and `names_to_match_against`, meeting a minimum threshold
#' outputting the test_name, matched_name and score.
#'
#' @param names_to_match List of names to match.
#' @param names_to_match_against List of names to be matched against.
#' @param threshold A threshold matching score to reach
#' @param ... Additional arguments are passed on to [stringdist::stringsim].
#'
#' @return Returns a tibble of all matching name combinations scoring above
#'  the threshold.
#' @export
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' loanbook_entities <- loanbook_demo %>%
#'   prepare_loanbook_for_matching()
#'
#' ald_entities <- ald_demo %>%
#'   prepare_ald_for_matching() %>%
#'   dplyr::mutate(simpler_name = replace_customer_name(.data$name))
#'
#' match_all_against_all(loanbook_entities$simpler_name,
#'              ald_entities$simpler_name)
match_all_against_all <- function(names_to_match, names_to_match_against, threshold = 0.95, ...) {
  purrr::map_dfr(.x = names_to_match,
          .f = match_one_name_against_all,
          names_to_match_against = names_to_match_against,
          threshold = threshold,
          ...
  )
}

match_one_name_against_all <- function(name_to_match, names_to_match_against, threshold, ...){
  result <- string_similarity(name_to_match, names_to_match_against, ...)

  tibble::tibble(
    test_value = replicate(length(names_to_match_against), name_to_match),
    matching_name = names_to_match_against,
    score = result
  ) %>%
    dplyr::filter(.data$score >= threshold)
}
