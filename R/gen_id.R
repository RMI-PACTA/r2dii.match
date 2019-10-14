#' Populate `id_direct_loantaker`, and `id_ultimate_parent` in the loanbook
#'
#' This function will generate identifiers for id_direct_loantaker and
#' id_ultimate_parent that are unique to every (Name,Sector) pair.
#'
#' @param data The input loanbook. See r2ii.dataraw for details.
#'
#' @return The input loanbook, with adjusted ids
#' @export
#'
#' @examples
#' lbk <- r2dii.dataraw::loanbook_demo
#' lbk_id_adjusted <- gen_id(lbk)
#' lbk_id_adjusted
gen_id <- function(data) {
  lbk_output <- data %>%
    mutate(
      id_direct_loantaker = dplyr::group_indices(
        .,
        .data$name_direct_loantaker,
        .data$sector_classification_direct_loantaker
      ),
      id_ultimate_parent = dplyr::group_indices(
        .,
        .data$name_ultimate_parent,
        .data$sector_classification_direct_loantaker
      )
    ) %>%
    mutate(
      id_direct_loantaker = paste0("C", .data$id_direct_loantaker),
      id_ultimate_parent = paste0("UP", .data$id_ultimate_parent)
    )
}
