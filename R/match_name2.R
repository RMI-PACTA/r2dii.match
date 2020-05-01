match_name2 <- function(loanbook, ald, ...) {
  undo <- function(x) rlang::set_names(names(x), unname(x))
  ald_ish <- dplyr::rename(ald, dplyr::all_of(undo(new_names_from_old_names())))

  match_name(loanbook = loanbook, ald = ald_ish, ...)
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


# # dplyr
# # > [1] '0.8.99.9002'
# ald_scenario_demo <- ald_demo %>%
#   rename(all_of(x)) %>%
#   select(-c(
#     "number_of_assets",
#     "is_ultimate_listed_owner",
#     "ald_timestamp"
#   )) %>%
#   mutate(id_name = "company_name", .before = 1L) %>%
#   mutate(
#     ald_emission_factor_unit = glue::glue("{ald_sector} emission_factor"),
#     .after = ald_emission_factor
#   ) %>%
#   inner_join(scenario_demo_2020_with_source, by = scenario_columns()) %>%
#   pick_ald_location_in_region() %>%
#   rename(scenario_region = region)
