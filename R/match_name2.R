sanitize_ald <- function(ald) {
  crucial <- c("name_company", "sector")
  is_ald <- all(purrr::map_lgl(crucial, ~rlang::has_name(ald, .x)))

  if (!is_ald) {
    undo <- function(x) rlang::set_names(names(x), unname(x))
    ald <- dplyr::rename(ald, dplyr::all_of(undo(new_names_from_old_names())))
  }

  ald
}


# Used in r2dii.data 0.0.3.9001 to create ald_scenario_demo from ald_demo (old)
new_names_from_old_names <- function() {
  c(
    "id" = "name_company",
    "ald_sector" = "sector",
    "technology" = "technology",
    "ald_production_unit" = "production_unit",
    "year" = "year",
    "ald_production" = "production",
    "ald_emission_factor" = "emission_factor",
    "domicile_region" = "country_of_domicile",
    "ald_location" = "plant_location",
    "is_ultimate_owner" = "is_ultimate_owner"
  )
}
