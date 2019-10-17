#' Simplify customer name
#'
#' @description Takes customer name and simplifies it by
#' converting to lower case; converting to latin-ascii characters;
#' converting ownership types to standard abbreviations.
#'
#' @return Character string with simplified name
#'
#' @export
#' @param name text string to simplify
#' @param cut.ownership flag that defines whether ownership type (like llc)
#'   should be cut-off from name during simplification
#' @param reduction data frame with reduction rules to be applied, contains
#'   columns From (for initial values) and To (for resulting values)
#' @param ownership vector of company ownership types to be disctinguished
#'   for cut-off or separation
#'
#' @examples
#' simplifyName("Acuity Brands Inc")
#' simplifyName(c("3M Company", "Abbott Laboratories", "AbbVie Inc.", "Accenture plc"))
simplifyName <- function(
  name,
  cut.ownership = FALSE,
  reduction = pacta::data.name.reductions,
  ownership = pacta::data.ownership.types
) {
  # replace long words with abbreviations
  substituteF <- function(text, abr) {
    from <- abr[1]
    to <- abr[2]
    gsub(from, to, text, fixed = T)
  }
  substituteR <- function(text, abr) {
    from <- abr[1]
    to <- abr[2]
    gsub(from, to, text)
  }

  replacements <-  list(
    c(".", " "),
    c(",", " "),
    #c("-", " "),
    c("_", " "),
    c("/", " "),
    c("$", "")
  )


  # convert dataframe reductions into list of abbreviation rules (From -> To pairs)
  abbreviations <- mapply(
    c, tolower(reduction$From), tolower(reduction$To),
    SIMPLIFY = FALSE, USE.NAMES = FALSE
  )

  ownerships <- Map(
    f = function(x) {
      if (cut.ownership) c(paste0(" ", x, "$"), "")
      else c(paste0(" ", x, "$"), paste0("$", x))
    },
    ownership
  )

  cleanName <- name

  # turn text to lowercase and translate to only base latin characters
  cleanName <- tolower(cleanName)
  cleanName <- stringi::stri_trans_general(cleanName, "any-latin")
  cleanName <- stringi::stri_trans_general(cleanName, "latin-ascii")

  # substitute words in text using list of replacements
  cleanName <- Reduce(f = substituteF, x = replacements, init = cleanName)

  # keep only one space between words
  cleanName <- gsub("[[:space:]]+", " ", cleanName)

  # substitute words in text using list of abbreviations
  cleanName <- Reduce(f = substituteF, x = abbreviations, init = cleanName)

  # trim redundant whitespaces
  cleanName <- trimws(cleanName,which = "both")

  # ?
  cleanName <- gsub("(?<=\\s[a-z]{1}) (?=[a-z]{1})", "", cleanName, perl = TRUE)

  # ownership type distinguished (with $ sign) in company name
  cleanName <- Reduce(f = substituteR, x = ownerships, init = cleanName)

  # final adjustments
  cleanName <- gsub("-", " ", cleanName)
  cleanName <- gsub("[[:space:]]", "", cleanName)
  cleanName <- gsub("[^[:alnum:][:space:]$]","",cleanName)
  cleanName <- gsub("$"," ", cleanName, fixed = T)

  return(cleanName)
}
