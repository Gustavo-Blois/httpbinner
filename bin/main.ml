open Httpbinner

let read_urls () =
  let rec read acc =
    match input_line stdin with
    | line ->
        let url = String.trim line in
        read (if url = "" then acc else url :: acc)
    | exception End_of_file -> List.rev acc
  in
  read []

let main (options : Cmd.options) =
  try
    let urls = if Utils.has_stdin () then read_urls () else [] in
    let headers = Cohttp.Header.of_list options.headers in
    let urls_and_tokens_lists =
      Lwt_main.run
        (Request.get_tokens_from_multiple_urls urls ~headers
           ~concurrency:options.concurrency ~silent:options.silent)
    in
    let bins = Bins.create_bins ~threshold:options.threshold urls_and_tokens_lists in
    let write channel =
      Hashtbl.iter (fun url (bin : Bins.bin) ->
        output_string channel (url ^ "\n");
        if not options.silent then begin
          output_string channel (Int64.to_string bin.fingerprint ^ "\n");
          output_string channel (String.concat ";" bin.domains ^ "\n")
        end) bins;
      flush channel
    in
    begin match options.output with
    | None -> write stdout
    | Some path ->
        let channel = open_out path in
        Fun.protect ~finally:(fun () -> close_out channel)
          (fun () -> write channel)
    end;
    Ok ()
  with
  | Sys_error message -> Error (`Msg message)

let () =
  let info = Cmdliner.Cmd.info "httpbinner"
    ~doc:"Group URLs from standard input based on response similarity."
  in
  exit (Cmdliner.Cmd.eval
    (Cmdliner.Cmd.v info Cmdliner.Term.(const main $ Cmd.options_t |> term_result)))
