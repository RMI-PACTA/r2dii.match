# Extract this here so it's available in all tests. This makes it easier to
# run individual tests interactively, after running devtools::load_all()
expect_names_match_name <- c(
  "id_loan",
  "id_direct_loantaker",
  "name_direct_loantaker",

  "id_intermediate_parent_1",
  "name_intermediate_parent_1",

  "id_ultimate_parent",
  "name_ultimate_parent",

  "loan_size_outstanding",
  "loan_size_outstanding_currency",
  "loan_size_credit_limit",
  "loan_size_credit_limit_currency",

  "sector_classification_system",
  "sector_classification_input_type",
  "sector_classification_direct_loantaker",

  "fi_type",
  "flag_project_finance_loan",
  "name_project",

  "lei_direct_loantaker",
  "isin_direct_loantaker",

  "id_2dii",
  "level",
  "sector",
  "sector_abcd",
  "name",
  "name_abcd",
  "score",
  "source",
  "borderline"
)
