Sys.setenv("OMP_THREAD_LIMIT" = 2)

library(testthat)
library(r2dii.match)

test_check("r2dii.match")
