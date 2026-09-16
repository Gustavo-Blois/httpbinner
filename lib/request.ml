open Lwt
open Cohttp
open Cohttp_lwt_unix
open Lwt.Syntax

let tokenize s =
  String.split_on_char ' ' s |> List.filter ((<>) "") |> List.map String.trim |>  List.filter ((<>) "")




let rec get_following ?(max_redirects = 5) ~headers uri =
  let* resp, body = Client.get ~headers uri in
  let code = resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status in
  match code with
  | 301 | 302 | 303 | 307 | 308 ->
      let* () = Cohttp_lwt.Body.drain_body body in
      if max_redirects <= 0 then
        Lwt.fail_with
          (Printf.sprintf "limite de redirects excedido em %s" (Uri.to_string uri))
      else begin
        match Cohttp.Header.get (Cohttp.Response.headers resp) "location" with
        | None ->
            Lwt.fail_with
              (Printf.sprintf "HTTP %d sem Location em %s" code (Uri.to_string uri))
        | Some loc ->
            (* Location pode ser relativo: "/pagina" *)
            let next = Uri.resolve "https" uri (Uri.of_string loc) in
            (* não vaza credencial para outro host *)
            let headers =
              if Uri.host next = Uri.host uri then headers
              else Cohttp.Header.remove headers "authorization"
            in
            get_following ~max_redirects:(max_redirects - 1) ~headers next
      end
  | _ -> Lwt.return (uri, resp, body)


let get_tokens_from_url url_str ~headers : string list Lwt.t =
  let* final_uri, resp, body = get_following ~headers (Uri.of_string url_str) in
  let code = resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status in
  if Cohttp.Code.is_success code then begin
    let* body_str = Cohttp_lwt.Body.to_string body in
    Lwt.return (tokenize body_str)
  end else begin
    let* () = Cohttp_lwt.Body.drain_body body in
    Lwt.fail_with
      (Printf.sprintf "HTTP %d em %s (origem: %s)" code
         (Uri.to_string final_uri) url_str)
  end

let get_tokens_safe ?(silent = false) url ~headers =
  Lwt.catch
    (fun () -> get_tokens_from_url url ~headers)
    (fun exn ->
      if not silent then
        Printf.eprintf "fail on %s: %s\n%!" url (Printexc.to_string exn);
      Lwt.return [])
let rec chunks n = function
  | [] -> []
  | l ->
      let rec take k acc = function
        | x :: xs when k > 0 -> take (k - 1) (x :: acc) xs
        | rest -> (List.rev acc, rest)
      in
      let chunk, rest = take n [] l in
      chunk :: chunks n rest

let get_tokens_from_multiple_urls ?(concurrency = 4) ?(silent = false) urls ~headers
    : (string * string list) list Lwt.t =
  if concurrency <= 0 then invalid_arg "concurrency deve ser > 0";
  let fetch url =
    Lwt.map (fun tokens -> (url, tokens)) (get_tokens_safe ~silent url ~headers)
  in
  chunks concurrency urls
  |> Lwt_list.map_s (Lwt_list.map_p fetch)
  |> Lwt.map List.concat
