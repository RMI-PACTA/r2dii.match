#' Overwrite `id_direct_loantaker` and `id_ultimate_parent` with unique values
#'
#' Given a loanbook dataframe, this function overwrites columns
#' `id_direct_loantaker` and `id_ultimate_parent` of a loanbook dataframe to
#' generate values that are unique by every combination of the columns
#' `name_ultimate_parent`, `name_direct_loantaker` and
#' `sector_classification_direct_loantaker`.
#'
#' @param data A loanbook dataframe.
#' @param id_column A String giving the name of an `id_` column.
#' @param prefix A string giving a prefix for the values of the `id_column`.
#'
#' @family internal-ish
#' @seealso [r2dii.dataraw::loanbook_description],
#'   [r2dii.dataraw::loanbook_demo].
#'
#' @return A loanbook dataframe with adjusted ids.
#' @export
#'
#' @examples
#' r2dii.dataraw::loanbook_demo %>%
#'   uniquify_id_column(id_column = "id_direct_loantaker", prefix = "C")
#'
#' r2dii.dataraw::loanbook_demo %>%
#'   uniquify_id_column(id_column = "id_ultimate_parent", prefix = "UP")
uniquify_id_column <- function(data, id_column, prefix) {
  crucial <- c(
    "sector_classification_direct_loantaker",
    get_name_var(id_column),
    id_column
  )
  check_crucial_names(data, crucial)

  out <- data
  out[id_column] <- paste0(prefix, id_var_group_indices(out, id_column))
  out
}

get_name_var <- function(id_var) {
  sub("^id_(.*)$", "name_\\1", id_var)
}

# Unique combination of `id_var` and `sector_classification_direct_loantaker`
id_var_group_indices <- function(data, id_var) {
  id_var <- rlang::sym(get_name_var(id_var))
  dplyr::group_indices(
    data, !!id_var, .data$sector_classification_direct_loantaker
  )
}
