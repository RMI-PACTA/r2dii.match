`%||%` <- function (x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

has_name <- function(x, name) {
  match(name, names(x), nomatch = 0L) > 0L
}
