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
#' library(dplyr)
#' library(r2dii.dataraw)
#'
#' loanbook_demo %>%
#'   select(id_direct_loantaker, everything()) %>%
#'   # To more clearly show the effect of uniquify_id_column()
#'   mutate(id_ultimate_parent = "anything")
#'
#' loanbook_demo %>%
#'   select(id_direct_loantaker, everything()) %>%
#'   uniquify_id_column(id_column = "id_direct_loantaker", prefix = "C")
#'
#' # Same
#' loanbook_demo %>%
#'   select(id_ultimate_parent, everything()) %>%
#'   # To more clearly show the effect of uniquify_id_column()
#'   mutate(id_ultimate_parent = "anything")
#'
#' loanbook_demo %>%
#'   select(id_ultimate_parent, everything()) %>%
#'   uniquify_id_column(id_column = "id_ultimate_parent", prefix = "C")
uniquify_id_column <- function(data, id_column, prefix) {
  name_column <- replace_prefix(id_column, to = "name")
  crucial <- c("sector_classification_direct_loantaker", name_column, id_column)
  check_crucial_names(data, crucial)

  out <- data
  out[id_column] <- paste0(prefix, group_indices_of(out, id_column))
  out
}

replace_prefix <- function(x, to) {
  sub("^([^_]+)_(.*)$", glue("{to}_\\2"), x)
}

# Unique combination of `id_var` and `sector_classification_direct_loantaker`
group_indices_of <- function(data, column_name) {
  col_name <- replace_prefix(column_name, to = "name")
  dplyr::group_indices(
    data, !!rlang::sym(col_name), .data$sector_classification_direct_loantaker
  )
}
