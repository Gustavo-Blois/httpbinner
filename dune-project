(lang dune 3.24)

(name httpbinner)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name httpbinner)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  ocaml
  cohttp
  cohttp-lwt-unix
  sha
  zarith
  cmdliner
  (alcotest :with-test)
  (qcheck-alcotest :with-test))
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
