(lang dune 3.24)

(name httpbinner)

(generate_opam_files true)

(source
 (github Gustavo-Blois/httpbinner))

(authors "Gustavo Blois <gustavobloist@gmail.com>")

(maintainers "Gustavo Blois <gustavobloist@gmail.com>")

(license "MIT")

(documentation https://github.com/Gustavo-Blois/httpbinner#readme)

(package
 (name httpbinner)
 (synopsis "A tool to group URLs")
 (description "A tool to group URLs using the SimHash algorithm")
 (depends
  ocaml
  cohttp
  cohttp-lwt-unix
  lwt_ssl
  sha
  zarith
  cmdliner
  (alcotest :with-test)
  (qcheck-alcotest :with-test))
 (tags
  ("http" "cli" "simhash")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
