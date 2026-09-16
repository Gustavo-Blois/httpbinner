open Cmdliner

type options = {
  threshold : int64;
  headers : (string * string) list;
  concurrency : int;
  output : string option;
  silent : bool;
  verbose : bool;
}

let header =
  let parse value =
    match String.index_opt value ':' with
    | None -> Error (`Msg "expected a header in NAME: VALUE format")
    | Some index ->
        let name = String.sub value 0 index |> String.trim in
        let contents =
          String.sub value (index + 1) (String.length value - index - 1)
          |> String.trim
        in
        if name = "" || String.contains value '\r' || String.contains value '\n' then
          Error (`Msg "invalid header")
        else Ok (name, contents)
  in
  let print fmt (name, value) = Format.fprintf fmt "%s: %s" name value in
  Arg.conv (parse, print)

let positive_int =
  let parse value =
    match int_of_string_opt value with
    | Some n when n > 0 -> Ok n
    | _ -> Error (`Msg "expected a positive integer")
  in
  Arg.conv (parse, Format.pp_print_int)

let nonnegative_int64 =
  let parse value =
    match Int64.of_string_opt value with
    | Some n when n >= 0L -> Ok n
    | _ -> Error (`Msg "expected a nonnegative integer")
  in
  Arg.conv (parse, fun fmt value -> Format.fprintf fmt "%Ld" value)

let options_t =
  let threshold =
    let doc = "Group fingerprints whose Hamming distance is below this threshold." in
    Arg.(value & opt nonnegative_int64 20L & info ["threshold"; "t"] ~docv:"INT" ~doc)
  in
  let headers =
    let doc = "Add a request header (NAME: VALUE). May be repeated." in
    Arg.(value & opt_all header [] & info ["header"; "H"] ~docv:"HEADER" ~doc)
  in
  let concurrency =
    let doc = "Maximum number of concurrent requests." in
    Arg.(value & opt positive_int 4 & info ["concurrency"; "c"] ~docv:"INT" ~doc)
  in
  let output =
    let doc = "Write results to FILE instead of standard output." in
    Arg.(value & opt (some string) None & info ["output"; "o"] ~docv:"FILE" ~doc)
  in
  let silent =
    let doc = "Output only one URL per bin and suppress request errors." in
    Arg.(value & flag & info ["silent"; "s"] ~doc)
  in
  let verbose =
    let doc = "Enable verbose output." in
    Arg.(value & flag & info ["verbose"; "v"] ~doc)
  in
  let make threshold headers concurrency output silent verbose =
    { threshold; headers; concurrency; output; silent; verbose }
  in
  Term.(const make $ threshold $ headers $ concurrency $ output $ silent $ verbose)
