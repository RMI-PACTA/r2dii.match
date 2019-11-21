test_that("overwrite_name_sector errors if overwrite lacks key column", {
  data <- loanbook_demo %>%
    bridge_sector() %>%
    pull_unique_name_sector_combinations()

  bad_overwrite <- tibble(x = 1)

  expect_error(
    overwrite_name_sector(data, bad_overwrite),
    "data must have all expected names"
  )
})

test_that("overwrite_name_sector correctly overwrites name", {
  data <- loanbook_demo %>%
    bridge_sector() %>%
    pull_unique_name_sector_combinations()

  overwrite <- overwrite_demo

  out <- overwrite_name_sector(data, overwrite) %>%
    dplyr::filter(id %in% overwrite$id & level %in% overwrite$level) %>%
    dplyr::left_join(overwrite, by = c("id", "level"), keep = F)

  expect_equal(out$name.x, out$name.y)
})

test_that("overwrite_name_sector correctly overwrites sector", {
  data <- loanbook_demo %>%
    bridge_sector() %>%
    pull_unique_name_sector_combinations()

  overwrite <- overwrite_demo

  out <- overwrite_name_sector(data, overwrite) %>%
    dplyr::filter(id %in% overwrite$id & level %in% overwrite$level) %>%
    dplyr::left_join(overwrite, by = c("id", "level"), keep = F)

  expect_equal(out$sector.x, out$sector.y)
})

test_that("overwrite_name_sector preserves names in `data`", {
  data <- loanbook_demo %>%
    bridge_sector() %>%
    pull_unique_name_sector_combinations()

  expect_equal(
    names(overwrite_name_sector(data, overwrite_demo)), names(data)
  )
})
