#' Bridge classification between portfolio's system and 2dii's standard
#'
#' This function adds two columns, `sector` and `borderline` to the input
#' portfolio, corresponding to the bridged sector classification.
#'
#' @param data A loanbook dataframe.
#'
#' @return A loanbook dataframe with additional `sector` and `borderline`
#'   columns.
#' @export
#'
#' @examples
#' sector_bridge(r2dii.dataraw::loanbook_demo)
sector_bridge <- function(data){

  # check that crucial columns are present in input data
  crucial <- c(
    "sector_classification_system",
    "sector_classification_direct_loantaker")

  # TODO: this must be removed. classification files must be read directly from
  # r2dii.dataraw NOTE: c("code", "sector", "borderline") are crucial columns in
  # *_classification.csv files, however they are managed by r2dii.dataraw. Best
  # practice to check for these fields in this function? or add a test for these
  # fields before incorporating the files into r2dii.dataraw
  nace_classification <- read.csv(
    "https://raw.githubusercontent.com/jdhoffa/r2dii.dataraw/classification-bridges/data-raw/nace_classification.csv"
  ) %>%
    select(code, sector, borderline)

  isic_classification <- read.csv(
    "https://raw.githubusercontent.com/jdhoffa/r2dii.dataraw/classification-bridges/data-raw/isic_classification.csv"
  ) %>%
    select(code, sector, borderline)


  data_classification_names <- c("nace", "isic")
  # data_classification_names <- unique(tolower(data$sector_classification_system))

  # TODO: swap next two lines once classification files are present in
  # r2dii.dataraw
  # data_classification <- data_classification_names %>%
  #   purrr::map_chr(~glue::glue("r2dii.dataraw::{.x}_classification"))
  data_classification <- data_classification_names %>%
    purrr::map_chr(~glue::glue("{.x}_classification"))

  data_classification <- data_classification %>%
    purrr::map(get) %>%
    purrr::set_names(data_classification_names)

  full_classification <- data.frame()

  # there's definitely a better way to do this
  for (name in data_classification_names){
    element <- data_classification[[name]] %>%
      mutate(code_system = toupper(name))
    full_classification <- full_classification %>%
      rbind(element)
  }

  data %>%
    left_join(
      full_classification,
      by = c(
        "sector_classification_system" = "code_system",
        "sector_classification_direct_loantaker" = "code"
      )
    )
}
