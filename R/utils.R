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

