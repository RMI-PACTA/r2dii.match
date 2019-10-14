#' Generate values to populate id_direct_loantaker, and id_ultimate_parent in the loanbook.csv
#'
#' This function will generate identifiers for id_direct_loantaker and id_ultimate_parent that are
#' unique to every (Name,Sector) pair.
#'
#' @param lbk The input loanbook. See r2ii.dataraw for details.
#'
#' @return lbk The input loanbook, with adjusted ids
#' @export
#'
#' @examples
#' lbk_id_adjusted <- gen_id(lbk)

library(tidyverse)
gen_id <- function(lbk_input){
  lbk_output <- lbk_input %>%
    mutate(id_direct_loantaker =group_indices(.,name_direct_loantaker,sector_classification_direct_loantaker),
           id_ultimate_parent = group_indices(.,name_ultimate_parent,sector_classification_direct_loantaker)) %>%
    mutate(id_direct_loantaker = paste0("C",id_direct_loantaker),
           id_ultimate_parent = paste0("UP", id_ultimate_parent))
}
