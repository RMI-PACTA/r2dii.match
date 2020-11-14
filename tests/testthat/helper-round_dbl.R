round_dbl <- function(data, digits = 4L) {
  data[detect_dbl(data)] <- lapply(data[detect_dbl(data)], round, digits = digits)
  data
}

detect_dbl <- function(data) {
  unlist(lapply(data, is.double))
}
