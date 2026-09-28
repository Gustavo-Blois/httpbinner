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

let rate_limited () =
  let throttle = Request.rate_limiter 20 in
  let start = Unix.gettimeofday () in
  Lwt_main.run (Lwt.join (List.init 5 (fun _ -> throttle ())));
  let elapsed = Unix.gettimeofday () -. start in
  (* 5 slots a 20 req/s: o primeiro é imediato, o último começa em 0.2s *)
  Alcotest.(check bool) "requests are spaced" true (elapsed >= 0.19);
  Alcotest.(check bool) "no excessive delay" true (elapsed < 0.5)

let () =
  Alcotest.run "request"
    [ "failures", [Alcotest.test_case "excluded from bins" `Quick failed_requests];
      "rate", [Alcotest.test_case "limits requests per second" `Quick rate_limited] ]
