#' @importFrom dplyr all_of filter select mutate left_join group_by ungroup
#' @importFrom dplyr if_else rename distinct slice pull
#' @importFrom glue glue
#' @importFrom purrr reduce
#' @importFrom rlang has_name set_names warn abort
#' @importFrom tibble tibble tribble as_tibble
#' @importFrom data.table setDT setkey :=
NULL

# Avoid warning due to ambiguous use of external vector to select df columns:
# https://github.com/RMI-PACTA/r2dii.match/pull/317
all_of_ <- function(x) {
  if (utils::packageVersion("tidyselect") >= "1.0.0") {
    tidyselect::all_of(x)
  } else {
    identity(x)
  }
}

globalVariables(
  c(
    ".",
    ".data",
    "alias_abcd",
    "alias_lbk",
    "id_2dii",
    "pick",
    "rowid",
    "score",
    "sector",
    "sector_abcd"
  )
)
