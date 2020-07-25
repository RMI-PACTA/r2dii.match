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
