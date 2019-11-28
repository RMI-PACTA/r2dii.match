#' Compute similarity scores between strings
#'
#' This function computes pairwise string similarities between elements of
#' character vectors `a` and `b`, where the vector with less elements is
#' recycled. It is a thin wrapper around `stringdist::stringdist()` with
#' defaults set to the most common parameters used in 2dii analyses.
#'
#' @inherit stringdist::stringsim
#'
#' @param method Method for distance calculation. One of `c("osa", "lv", "dl",
#'   "hamming", "lcs", "qgram", "cosine", "jaccard", "jw", "soundex")`. See
#'   [stringdist::stringdist-metrics].
#' @inheritParams stringdist::stringdist
#' @param ... Additional arguments are passed on to [stringdist::stringsim].
#'
#' @seealso [stringdist::stringsim], [stringdist::stringdist].
#'
#' @export
#' @examples
#' # Clear extreemes
#' string_similarity("aa", "aa")
#' string_similarity("aa", "bb")
#'
#' # Unclear extreemes
#' string_similarity("ab", "ba")
#'
#' identical(
#'   string_similarity("ab", "ac"),
#'   string_similarity("ac", "ab")
#' )
#'
#' string_similarity(c("fewer", "items", "get", "recycled"), "recycled")
string_similarity <- function(a, b, ..., method = "jw", p = 0.1) {
  ellipsis::check_dots_used()
  stringdist::stringsim(a, b, ..., method = method, p = p)
}
