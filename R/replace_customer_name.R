#' Replace customer names
#'
#' * `replace_customer_name()` takes any character vector, usually a vector of
#' customer names, and replaces (a) to lower case; (b) to latin-ascii
#' characters; and (c) to standard abbreviations of ownership types.
#' * `get_replacements()` allows you to access the default replacements table,
#' so you can amend it and pass it to `replace_customer_name()` via the
#' `from_to` argument.
#'
#' @author person(given = "Evgeny",
#' family = "Petrovsky",
#' role = c("aut", "ctr"))
#'
#' @param x Character string, (likely) containing customer names.
#' @param from_to A dataframe with replacement rules to be applied, contains
#'   columns `from` (for initial values) and `to` (for resulting values).
#' @param ownership vector of company ownership types to be distinguished for
#'   cut-off or separation.
#' @param remove_ownership Flag that defines whether ownership type (like llc)
#'   should be cut-off.
#'
#' @export
#' @return
#' * `replace_customer_name()` returns a character string.
#' * `get_replacements()` returns a [dplyr::tibble] with columns `from` and
#' `to`.
#'
#' @examples
#' library(dplyr)
#'
#' replace_customer_name("A. and B")
#' replace_customer_name("Acuity Brands Inc")
#' replace_customer_name(c("3M Company", "Abbott Laboratories", "AbbVie Inc."))
#'
#' custom_replacement <- tibble(from = "AAAA", to = "B")
#' replace_customer_name("Aa Aaaa", from_to = custom_replacement)
#'
#' neutral_replacement <- tibble(from = character(0), to = character(0))
#' replace_customer_name("Company Name Owner", from_to = neutral_replacement)
#' replace_customer_name(
#'   "Company Name Owner",
#'   from_to = neutral_replacement,
#'   ownership = "owner",
#'   remove_ownership = TRUE
#' )
#'
#' get_replacements()
#'
#' append_replacements <- get_replacements() %>%
#'   add_row(
#'     .before = 1,
#'     from = c("AA", "BB"), to = c("alpha", "beta")
#'   )
#' append_replacements
#'
#' # And in combination with `replace_customer_name()`
#' replace_customer_name(c("AA", "BB", "1"), from_to = append_replacements)
replace_customer_name <- function(x,
                                  from_to = NULL,
                                  ownership = NULL,
                                  remove_ownership = FALSE) {
  # lowercase
  out <- tolower(x)

  # base latin characters
  out <- stringi::stri_trans_general(out, "any-latin")
  out <- stringi::stri_trans_general(out, "latin-ascii")

  # symbols
  out <- reduce(get_sym_replace(), replace_abbrev, fixed = TRUE, .init = out)

  # only one space between words
  out <- gsub("[[:space:]]+", " ", out)

  out <- replace_with_abbreviation(from_to, .init = out)

  # trim redundant whitespaces
  out <- trimws(out, which = "both")

  # ?
  out <- gsub("(?<=\\s[a-z]{1}) (?=[a-z]{1})", "", out, perl = TRUE)

  out <- maybe_remove_ownership(remove_ownership, ownership, .init = out)

  # final adjustments
  out <- gsub("-", " ", out)
  out <- gsub("[[:space:]]", "", out)
  out <- gsub("[^[:alnum:][:space:]$]", "", out)
  out <- gsub("$", " ", out, fixed = T)

  out
}

maybe_remove_ownership <- function(remove_ownership, ownership, .init) {
  ownership <- ownership %||% get_ownership_type()

  # ownership type distinguished (with $ sign) in company name
  paste_or_not <- function(x, remove_ownership) {
    if (remove_ownership) {
      c(paste0(" ", x, "$"), "")
    } else {
      c(paste0(" ", x, "$"), paste0("$", x))
    }
  }

  out <- purrr::map(ownership, ~ paste_or_not(.x, remove_ownership))
  reduce(out, replace_abbrev, .init = .init)
}

replace_with_abbreviation <- function(replacement, .init) {
  replacement <- replacement %||% get_replacements()
  replacement <- stats::setNames(replacement, tolower(names(replacement)))

  check_crucial_names(replacement, c("from", "to"))

  abbrev <- purrr::map2(tolower(replacement$from), tolower(replacement$to), c)

  reduce(abbrev, replace_abbrev, fixed = TRUE, .init = .init)
}

# replace long words with abbreviations
replace_abbrev <- function(text, abr, fixed = FALSE) {
  from <- abr[1]
  to <- abr[2]
  gsub(from, to, text, fixed = fixed)
}

# Source: @jdhoffa https://github.com/2DegreesInvesting/r2dii.dataraw/pull/8
#' @export
#' @rdname replace_customer_name
get_replacements <- function() {
  tribble(
    ~from, ~to,
    " and ", " & ",
    " en ", " & ",
    " och ", " & ",
    " und ", " & ",
    "(pjsc)", "",
    "(pte)", "",
    "(pvt)", "",
    "0", "null",
    "1", "one",
    "2", "two",
    "3", "three",
    "4", "four",
    "5", "five",
    "6", "six",
    "7", "seven",
    "8", "eight",
    "9", "nine",
    "aktg", "ag",
    "associate", "assoc",
    "associates", "assoc",
    "berhad", "bhd",
    "company", "co",
    "corporation", "corp",
    "designated activity company", "dac",
    "development", "dev",
    "finance", "fine",
    "financial", "fina",
    "financial", "fin",
    "financing", "fing",
    "generation", "gen",
    "generation", "gen",
    "golden", "gld",
    "government", "govt",
    "groep", "grp",
    "group", "grp",
    "holding", "hldgs",
    "holdings", "hldgs",
    "incorporated", "inc",
    "international", "intl",
    "investment", "invest",
    "investment", "invest",
    "limited", "ltd",
    "limited partnership", "lp",
    "ltd liability co", "llc",
    "ograniczona odpowiedzialnoscia", "oo",
    "partner", "prt",
    "partners", "prt",
    "public co ltd", "pcl",
    "public ltd co", "plc",
    "resource", "res",
    "resources", "res",
    "san tic anonim sti", "santicanonimsti",
    "san tic ltd sti", "santicltdsti",
    "sanayi", "san",
    "sanayi ve ticaret", "sanayi ticaret",
    "shipping", "shp",
    "sirketi", "sti",
    "sp z o o", "spzoo",
    "sp z oo", "spzoo",
    "spolka z ", "sp z ",
    "ticaret", "tic"
  )
}

# Technology mix for analysis
get_ownership_type <- function() {
  c(
    "ab",
    "ag",
    "as",
    "asa",
    "bhd",
    "bsc",
    "bv",
    "co",
    "corp",
    "cv",
    "dac",
    "gmbh",
    "govt",
    "hldgs",
    "inc",
    "intl",
    "jsc",
    "llc",
    "lp",
    "ltd",
    "nv",
    "pcl",
    "pjsc",
    "plc",
    "pt",
    "pte",
    "sa",
    "sarl",
    "sas",
    "se",
    "spa",
    "spzoo",
    "srl"
  )
}

# replace each lhs with rhs
get_sym_replace <- function() {
  list(
    c(".", " "),
    c(",", " "),
    # c("-", " "),
    c("_", " "),
    c("/", " "),
    c("$", "")
  )
}
