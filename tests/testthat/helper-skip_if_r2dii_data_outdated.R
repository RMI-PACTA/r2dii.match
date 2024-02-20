skip_if_r2dii_data_outdated <- function() {
  skip_if(
    packageVersion("r2dii.data") <= "0.4.1",
    "We expect different output"
  )
}
