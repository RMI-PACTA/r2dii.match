`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

extract_level_names <- function(data, prefix) {
  extract_names(data, paste0(prefix, level(), collapse = "|"))
}

extract_names <- function(x, pattern) {
  grep(pattern, names(x), value = TRUE)
}

level <- function() {
  c("direct", "intermediate", "ultimate")
}

# Helpers to create mini data ---------------------------------------------

# mini_lbk(loanbook_demo, 1)
mini_lbk <- function(loanbook, ..., vars = crucial_lbk()) {
  loanbook %>%
    dplyr::slice(...) %>%
    dplyr::select(vars, tidyselect::matches("intermediate"))
}

# loanbook_demo %>%
#   mini_lbk(1) %>%
#   mini_ald()
mini_ald <- function(loanbook, alias_ald = NULL) {
  alias_ald <- alias_ald %||% alias_ald()
  alias_ald %>%
    filter(.data$alias_ald %in% pull_alias_ald(loanbook, .))
}

# alias_ald()
alias_ald <- function() {
  r2dii.dataraw::ald_demo %>%
    dplyr::select(crucial_ald()) %>%
    dplyr::mutate(alias_ald = to_alias(.data$name_company)) %>%
    unique()
}

pull_alias_ald <- function(loanbook, ald) {
  loanbook %>%
    match_name(ald) %>%
    dplyr::select(dplyr::ends_with("ald")) %>%
    dplyr::pull(.data$alias_ald)
}

crucial_lbk <- function() {
  c(
    "id_ultimate_parent",
    "name_ultimate_parent",
    "id_direct_loantaker",
    "name_direct_loantaker",
    "sector_classification_system",
    "sector_classification_direct_loantaker"
  )
}

crucial_ald <- function() {
  c("name_company", "sector")
}
