#' Overwrite `id_direct_loantaker` and `id_ultimate_parent` with unique values
#'
#' Given a loanbook dataframe, this function overwrites columns
#' `id_direct_loantaker` and `id_ultimate_parent` of a loanbook dataframe to
#' generate values that are unique by every combination of the columns
#' `name_direct_loantaker` and `sector_classification_direct_loantaker`.
#'
#' @param data A loanbook dataframe.
#'
#' @family internal-ish
#' @seealso [r2dii.dataraw::loanbook_description],
#'   [r2dii.dataraw::loanbook_demo].
#'
#' @return A loanbook dataframe with adjusted ids.
#' @export
#'
#' @examples
#' id_by_loantaker_sector(r2dii.dataraw::loanbook_demo)
id_by_loantaker_sector <- function(data) {
  crucial <- c(
    "name_direct_loantaker",
    "sector_classification_direct_loantaker",
    "name_ultimate_parent",
    "id_direct_loantaker",
    "id_ultimate_parent"
  )
  check_crucial_names(data, crucial)

  data %>%
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
