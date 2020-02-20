Write the output of `match_name()` into a .csv file with:

```r
# Writting to current working directory
matched %>%
  readr::write_csv("matched.csv")
```

Compare, edit, and save the data manually:

* Open _matched.csv_ with any spreadsheet editor (e.g. MS Excel, Google Sheets).
* Compare the columns `name` and `name_ald` manually to determine if the match is valid. Other information can be used in conjunction with just the names to ensure the two entities match (sector, internal information on the company structure, etc.)
* Edit the data:
    * If you are happy with the match, set the `score` value to `1`.
    * Otherwise set or leave the `score` value to anything other than `1`.
* Save the edited file as, say, _valid_matches.csv_.

Re-read the edited file (validated) with:

```r
# Reading from current working directory
valid_matches <- readr::read_csv("valid_matches.csv")
```
