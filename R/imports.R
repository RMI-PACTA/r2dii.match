#' @importFrom dplyr filter select mutate left_join group_by ungroup
#' @importFrom dplyr if_else rename distinct
#' @importFrom glue glue
#' @importFrom purrr reduce
#' @importFrom rlang has_name set_names warn abort
#' @importFrom tibble tibble tribble
#' @import data.table
NULL

globalVariables(c(".data", ".", "alias_lbk", "alias_ald", "score"))
