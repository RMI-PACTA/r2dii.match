#' @importFrom dplyr filter select mutate left_join group_by ungroup
#' @importFrom dplyr if_else rename distinct
#' @importFrom glue glue
#' @importFrom purrr reduce
#' @importFrom rlang has_name set_names warn abort
#' @importFrom tibble tibble tribble as_tibble
#' @import data.table
NULL

globalVariables(
  c(
    ".",
    ".data",
    "alias_ald",
    "alias_lbk",
    "id_2dii",
    "pick",
    "score",
    "sector",
    "sector_ald"
  )
)
