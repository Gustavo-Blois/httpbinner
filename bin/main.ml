open Httpbinner
let main () = 
  let headers = Cohttp.Header.init () in
  let tokens : string list list = 
    Lwt_main.run(Request.get_tokens_from_multiple_urls ["https://example.com";"https://pudim.com.br"] ~headers)
  in
  print_endline @@ Int64.to_string @@ Simhash.distance_between_texts Simhash.hamming_distance (List.hd tokens) (List.nth tokens 1)

let () = main ()
