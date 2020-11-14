#' @importFrom dplyr filter select mutate left_join group_by ungroup
#' @importFrom dplyr if_else rename distinct slice pull
#' @importFrom glue glue
#' @importFrom purrr reduce
#' @importFrom rlang has_name set_names warn abort
#' @importFrom tibble tibble tribble as_tibble
#' @importFrom data.table setDT setkey :=
NULL

all_of <- function(x) {
  if (utils::packageVersion("tidyselect") >= "1.0.0") {
    tidyselect::all_of
  } else {
    identity
  }
}

globalVariables(
  c(
    ".",
    ".data",
    "alias_ald",
    "alias_lbk",
    "id_2dii",
    "pick",
    "rowid",
    "score",
    "sector",
    "sector_ald"
  )
)
