#' Match a loanbook to asset-based company data (abcd) by the `name_*` columns
#'
#' `match_name()` scores the match between names in a loanbook dataset (columns
#' can be `name_direct_loantaker`, `name_intermediate_parent*` and
#' `name_ultimate_parent`) with names in an asset-based company data (column
#' `name_company`). The raw names are first internally transformed, and aliases
#' are assigned. The similarity between aliases in each of the loanbook and abcd
#'  is scored using [stringdist::stringsim()].
#'
#' @section Package options:
#' `r2dii.match.sector_classifications`: Allows you to use your own
#' `sector_classififications` instead of the default. This feature is
#' experimental and may be dropped and/or become a new argument to
#' `match_name()`.
#'
#' @template alias-assign
#' @template ignores-but-preserves-existing-groups
#'
#' @param loanbook,abcd data frames structured like [r2dii.data::loanbook_demo]
#'   and [r2dii.data::abcd_demo].
#' @param by_sector Should names only be compared if companies belong to the
#'   same `sector`?
#' @param min_score A number between 0-1, to set the minimum `score` threshold.
#'   A `score` of 1 is a perfect match.
#' @param method Method for distance calculation. One of `c("osa", "lv", "dl",
#'   "hamming", "lcs", "qgram", "cosine", "jaccard", "jw", "soundex")`. See
#'   [stringdist::stringdist-metrics].
#' @inheritParams stringdist::stringdist
#' @param overwrite A data frame used to overwrite the `sector` and/or `name`
#'   columns of a particular direct loantaker or ultimate parent. To overwrite
#'   only `sector`, the value in the `name` column should be `NA` and
#'   vice-versa. This file can be used to manually match loanbook companies to
#'   abcd.
#' @param ... Arguments passed on to [stringdist::stringsim()].
#' @param ald `r lifecycle::badge('superseded')` `ald` has been superseded by
#'   `abcd`.
#'
#' @family main functions
#'
#' @return A data frame with the same groups (if any) and columns as `loanbook`,
#'   and the additional columns:
#'   * `id_2dii` - an id used internally by `match_name()` to distinguish
#'   companies
#'   * `level` - the level of granularity that the loan was matched at
#'   (e.g `direct_loantaker` or `ultimate_parent`)
#'   * `sector` - the sector of the `loanbook` company
#'   * `sector_abcd` - the sector of the `abcd` company
#'   * `name` - the name of the `loanbook` company
#'   * `name_abcd` - the name of the `abcd` company
#'   * `score` - the score of the match (manually set this to `1`
#'   prior to calling `prioritize()` to validate the match)
#'   * `source` - determines the source of the match. (equal to `loanbook`
#'   unless the match is from `overwrite`
#'
#'   The returned rows depend on the argument `min_value` and the result of the
#'   column `score` for each loan: * If any row has `score` equal to 1,
#'   `match_name()` returns all rows where `score` equals 1, dropping all other
#'   rows. * If no row has `score` equal to 1,`match_name()` returns all rows
#'   where `score` is equal to or greater than `min_score`. * If there is no
#'   match the output is a 0-row tibble with the expected column names -- for
#'   type stability.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(r2dii.data)
#' library(tibble)
#'
#' # Small data for examples
#' loanbook <- head(loanbook_demo, 50)
#' abcd <- head(abcd_demo, 50)
#'
#' match_name(loanbook, abcd)
#'
#' match_name(loanbook, abcd, min_score = 0.9)
#'
#' # Use your own `sector_classifications`
#' your_classifications <- tibble(
#'   sector = "power",
#'   borderline = FALSE,
#'   code = "3511",
#'   code_system = "XYZ"
#' )
#'
#' restore <- options(r2dii.match.sector_classifications = your_classifications)
#'
#' loanbook <- tibble(
#'   sector_classification_system = "XYZ",
#'   sector_classification_direct_loantaker = "3511",
#'   id_ultimate_parent = "UP15",
#'   name_ultimate_parent = "Alpine Knits India Pvt. Limited",
#'   id_direct_loantaker = "C294",
#'   name_direct_loantaker = "Yuamen Xinneng Thermal Power Co Ltd"
#' )
#'
#' abcd <- tibble(
#'   name_company = "alpine knits india pvt. limited",
#'   sector = "power"
#' )
#'
#' match_name(loanbook, abcd)
#'
#' # Cleanup
#' options(restore)
#' }
match_name <- function(loanbook,
                       abcd,
                       by_sector = TRUE,
                       min_score = 0.8,
                       method = "jw",
                       p = 0.1,
                       overwrite = NULL,
                       ald = deprecated(),
                       ...) {
  restore <- options(datatable.allow.cartesian = TRUE)
  on.exit(options(restore), add = TRUE)

  if (lifecycle::is_present(ald)) {
    lifecycle::deprecate_warn(
      "0.1.0 (expected July 2022)",
      "match_name(ald)",
      "match_name(abcd)"
      )
    abcd <- ald
  }

  match_name_impl(
    loanbook = loanbook,
    abcd = abcd,
    by_sector = by_sector,
    min_score = min_score,
    method = method,
    p = p,
    overwrite = overwrite,
    ...
  )
}

match_name_impl <- function(loanbook,
                            abcd,
                            by_sector = TRUE,
                            min_score = 0.8,
                            method = "jw",
                            p = 0.1,
                            overwrite = NULL,
                            ...) {
  old_groups <- dplyr::groups(loanbook)
  loanbook <- ungroup(loanbook)

  abort_if_duplicated_id_loan(loanbook)
  if (!allow_reserved_columns()) abort_reserved_column(loanbook)
  loanbook_rowid <- tibble::rowid_to_column(loanbook)

  prep_lbk <- restructure_loanbook(loanbook_rowid, overwrite = overwrite)
  prep_abcd <- restructure_abcd(abcd)

  if (by_sector) {
    a <- expand_alias(prep_lbk, prep_abcd)
  } else {
    a <- tidyr::crossing(alias_lbk = prep_lbk$alias, alias_abcd = prep_abcd$alias)
  }

  setDT(a)

  if (identical(nrow(a), 0L)) {
    rlang::warn("Found no match.")
    return(empty_loanbook_tibble(loanbook, old_groups))
  }

  a <- unique(a)[
    ,
    score := stringdist::stringsim(
      alias_lbk, alias_abcd,
      method = method, p = p, ...
    )
  ]
  setkey(a, score)
  a <- a[score >= min_score, ]

  if (identical(nrow(a), 0L)) {
    rlang::warn("Found no match.")
    return(empty_loanbook_tibble(loanbook, old_groups))
  }

  l <- rename(prep_lbk, alias_lbk = "alias")
  setDT(l)
  matched <- a[l, on = "alias_lbk", nomatch = 0]
  matched <- matched[,
    pick := none_is_one(score) | some_is_one(score),
    by = id_2dii
  ][pick == TRUE][, pick := NULL]

  prep_abcd <- rlang::set_names(prep_abcd, paste0, "_abcd")
  setDT(prep_abcd)
  matched <- prep_abcd[matched, on = "alias_abcd"]

  if (by_sector) {
    matched <- matched[sector == sector_abcd, ]
  }

  # Restore columns from loanbook
  setDT(loanbook_rowid)
  maybe_columns <- c("rowid", "sector", "borderline")
  join_on <- intersect(maybe_columns, names(loanbook_rowid))
  matched <- loanbook_rowid[matched, on = join_on]
  matched <- matched[, rowid := NULL]
  matched <- as_tibble(matched)

  matched <- reorder_names_as_in_loanbook(matched, loanbook_rowid)
  matched <- unsuffix_and_regroup(matched, old_groups)
  matched <- select(matched, -all_of(c("alias", "alias_abcd")))
  # Remove attribute added by data.table
  attr(matched, ".internal.selfref") <- NULL

  matched
}

allow_reserved_columns <- function() {
  isTRUE(getOption("r2dii.match.allow_reserved_columns"))
}

abort_reserved_column <- function(data) {
  reserved_chr <- c("alias", "rowid", "sector")
  is_reserved <- names(data) %in% reserved_chr

  if (any(is_reserved)) {
    bad <- paste0(sort(names(data)[is_reserved]), collapse = ", ")
    abort(
      class = "reserved_column",
      glue("`loanbook` can't have reserved columns:\n{bad}")
    )
  }

  invisible(data)
}

abort_if_duplicated_id_loan <- function(loanbook) {
  column <- "id_loan"
  if (!has_name(loanbook, column)) {
    return(invisible(loanbook))
  }

  x <- loanbook[[column]]
  dupl <- anyDuplicated(x)
  if (dupl == 0L) {
    return(invisible(loanbook))
  }

  first <- x[[dupl]]
  msg <- glue("
    All values of `{column}` in a `loanbook` must be unique (`{first}` is not).
    Please ensure that every loan has a unique identifier.
  ")
  abort(msg, class = "duplicated_id_loan")

  invisible(loanbook)
}

empty_loanbook_tibble <- function(loanbook, old_groups) {
  types <- loanbook %>%
    purrr::map_chr(typeof)

  out <- named_tibble(names = minimum_names_of_match_name(loanbook)) %>%
    unsuffix_and_regroup(old_groups) %>%
    select(-all_of(c("alias", "alias_abcd")))

  tmp <- tempfile()
  utils::write.csv(out, tmp, row.names = FALSE)
  utils::read.csv(tmp, stringsAsFactors = FALSE, colClasses = types) %>%
    as_tibble()
}

# readr -------------------------------------------------------------------

expand_alias <- function(loanbook, abcd) {
  vars <- c("sector", "alias")
  l <- nest_by(select(loanbook, all_of_(vars)), .data$sector, .key = "alias_lbk")
  a <- nest_by(select(abcd, all_of_(vars)), .data$sector, .key = "alias_abcd")
  la <- dplyr::inner_join(l, a, by = "sector")

  purrr::map2_df(
    la$alias_lbk, la$alias_abcd,
    ~ tidyr::expand_grid(alias_lbk = .x$alias, alias_abcd = .y$alias)
  )
}

# Similar to nest_by() from dplyr >= 1.0.0, but works with dplyr >= 0.8.5
nest_by <- function(.data, ..., .key = "data") {
  grouped <- dplyr::group_by(.data, ...)
  nested <- tidyr::nest(grouped)
  dplyr::rename(nested, !!.key := "data")
}

unsuffix_and_regroup <- function(data, old_groups) {
  data %>%
    rename(alias = "alias_lbk") %>%
    group_by(!!!old_groups)
}

named_tibble <- function(names) {
  slice(as_tibble(set_names(as.list(names))), 0L)
}

minimum_names_of_match_name <- function(loanbook) {
  unique(c(names(loanbook), names_added_by_match_name()))
}

none_is_one <- function(x) {
  all(x != 1L)
}

some_is_one <- function(x) {
  any(x == 1L) & x == 1L
}

reorder_names_as_in_loanbook <- function(data, loanbook) {
  names_in_loanbook <- data %>%
    intersect_names_as_in(reference = loanbook)

  data %>%
    select(
      all_of_(names_in_loanbook),
      # New names
      !!!names_added_by_match_name(),
      # In case I missed something
      dplyr::everything()
    )
}

# What names of `data` exist in `reference`? (order from reference)
intersect_names_as_in <- function(data, reference) {
  missing_names <- setdiff(names(reference), names(data))
  setdiff(names(reference), missing_names)
}

names_added_by_match_name <- function() {
  c(
    "id_2dii",
    "level",
    "sector",
    "sector_abcd",
    "name",
    "name_abcd",
    "alias_lbk",
    "alias_abcd",
    "score",
    "source",
    "borderline"
  )
}
