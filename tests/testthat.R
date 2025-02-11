library(testthat)
library(r2dii.match)

Sys.setenv("OMP_THREAD_LIMIT" = 2)
test_check("r2dii.match")
