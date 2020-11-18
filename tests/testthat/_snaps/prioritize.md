# error if score=1 & values by id_loan+level are duplicated (#114)

    Code
      prioritize(invalid)
    Error <duplicated_score1_by_id_loan_by_level>
      `data` where `score` is `1` must be unique by `id_loan` by `level`.
      Duplicated rows: 2.
      Have you ensured that only one ald-name per loanbook-name is set to `1`?

