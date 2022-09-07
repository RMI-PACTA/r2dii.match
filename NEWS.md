# r2dii.match 0.1.1

* Maintenance release. 

# r2dii.match 0.1.0

* New argument `abcd` of `match_name()` supersedes the argument `ald` (#399). 

# r2dii.match 0.0.11

* Maintenance release.

# r2dii.match 0.0.10

* Maintenance release.

# r2dii.match 0.0.9

* With `options(r2dii.match.sector_classifications = own)` users can inject
  their `own` `sector_classififications` instead of the default
  `r2dii.data::sector_classifications`. With this feature, user may or may not
  choose to request their `sector_classifications` to be added to r2dii.data. 
  This feature is experimental and may be dropped and/or become a new argument
  to `match_name()` (#356 @georgeharris2deg @daisy-pacheco)`.

* `match_name()` now errors if the column `id_loan` of the input loanbook has
  any duplicated value `id_loan` (@georgeharris2deg #349).

# r2dii.match 0.0.8

* Maintenance release.

# r2dii.match 0.0.7

* `match_name()` gains `...` to pass additional arguments to
  `stringdist::stringsim()` (@evgeniadimi #310).

# r2dii.match 0.0.6

* `prioritize()` with 0-row input now returns the input untouched (#284).
* Fix `match_name()`: Remove dependency on `nest_by()` from dplyr 1.0.0 (#303).

# r2dii.match 0.0.5

* Change license to MIT.
* Increment lifecycle badge to "Maturing".
* The website's home page now thanks funders.
* New article on using `match_name()` with large loanbooks.
* The News tab of the website now shows all releases to date.

# r2dii.match 0.0.4

* New article "Calculating matching coverage" (#264).
* `match_name()` now outputs a new column `borderline` (#258).
* New `crucial_lbk()` helps select the minimum loanbook columns for
  `match_name()` to run (#236).
* `match_name()` now runs faster and uses less memory (@georgeharris2deg #214).
* `match_name()` now converts `ald$sector` to lower case before matching
  (@georgeharris2deg #257). It now returns identical output with, for example, 
  either "POWER" or "power". Notice that the input "POWER" in `ald$sector`
  becomes "power" in the column `sector_ald` of the output.
* `match_name()` now errors with a more informative message if `loanbook` has
  reserved columns -- `alias`, `rowid`, or `sector` (#233).

# r2dii.match 0.0.3

* Enforce dplyr >= 0.8.5 (#216).
* No longer import vctrs; it is unused.

# r2dii.match 0.0.2

This version includes only [internal changes](https://github.com/2DegreesInvesting/r2dii.match/releases/tag/v0.0.2). 

# r2dii.match 0.0.1

* First release on CRAN.
