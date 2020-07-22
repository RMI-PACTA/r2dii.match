`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

extract_level_names <- function(data, prefix) {
  pattern <- paste0(prefix, level(), collapse = "|")
  columns <- select(data, tidyselect::matches(pattern))
  names(columns)
}

level <- function() {
  c("direct", "intermediate", "ultimate")
}

commas <- function(...) paste0(..., collapse = ", ")

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
