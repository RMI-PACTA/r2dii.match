#' Score the similarity between two strings
#'
#' This function computes pairwise string similarities between elements of
#' character vectors `a` and `b`, where the vector with less elements is
#' recycled. It is a thin wrapper around `stringdist::stringdist()` with
#' defaults set to the most common parameters used in 2dii analyses.
#'
#' @inherit stringdist::stringsim
#'
#' @inheritParams match_name
#' @inheritParams stringdist::stringdist
#'
#' @seealso [stringdist::stringsim], [stringdist::stringdist].
#'
#' @examples
#' # Clear extreemes
#' score_string_similarity("aa", "aa")
#' score_string_similarity("aa", "bb")
#'
#' # Unclear extreemes
#' score_string_similarity("ab", "ba")
#'
#' identical(
#'   score_string_similarity("ab", "ac"),
#'   score_string_similarity("ac", "ab")
#' )
#'
#' score_string_similarity(c("fewer", "items", "get", "recycled"), "recycled")
#' @noRd
score_string_similarity <- function(a, b, method = "jw", p = 0.1) {
  stringdist::stringsim(a, b, method = method, p = p)
}
