let has_stdin () =
  (Unix.fstat Unix.stdin).Unix.st_kind <> Unix.S_CHR