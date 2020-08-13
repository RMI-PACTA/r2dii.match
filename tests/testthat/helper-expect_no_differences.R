expect_no_differences <- function(object, file) {
  # 1. Capture object and label
  act <- testthat::quasi_label(rlang::enquo(object), arg = "object")

  # 2. Call expect()
  ref <- readRDS(file)
  rownames(ref) <- NULL
  actual <- act$val
  rownames(actual) <- NULL

  expect(
    identical(act$val, ref),
    waldo::compare(actual, ref)
  )

  # 3. Invisibly return the value
  invisible(act$val)
}
