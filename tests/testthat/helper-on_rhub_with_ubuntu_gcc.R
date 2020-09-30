on_platform_that_fails_misteriously <- function() {
  identical(Sys.getenv("RHUB_PLATFORM"), "linux-x86_64-ubuntu-gcc")
}
