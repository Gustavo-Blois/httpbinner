open Httpbinner

let failed_requests () =
  let headers = Cohttp.Header.init () in
  let results =
    Lwt_main.run
      (Request.get_tokens_from_multiple_urls ~silent:true
         ["http://[invalid"; "http://[also-invalid"] ~headers)
  in
  Alcotest.(check int) "no failed requests returned" 0 (List.length results);
  Alcotest.(check int) "no bins for failed requests" 0
    (Hashtbl.length (Bins.create_bins results))

let () =
  Alcotest.run "request"
    ["failures", [Alcotest.test_case "excluded from bins" `Quick failed_requests]]
