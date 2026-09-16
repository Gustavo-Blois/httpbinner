open Simhash
type bin = {
  url: string;
  fingerprint: int64;
  mutable domains: string list;
}

let create_bins ?(threshold=20L) = function
  | [] ->
      Hashtbl.create ~random:true 30

  | (url, tokens) :: rest ->
      let first_fingerprint = simhash tokens in
      let first_bin = {
        url;
        fingerprint = first_fingerprint;
        domains = [url];
      } in

      let bins = Hashtbl.create ~random:true 30 in
      Hashtbl.add bins first_bin.url first_bin;

      let rec create_bins_i = function
        | [] -> ()

        | (url, tokens) :: ps ->
            let fingerprint = simhash tokens in
            let min_distance = ref Int64.max_int in
            let current_bin = ref first_bin in

            Hashtbl.iter
              (fun _ bin ->
                let distance =
                  hamming_distance bin.fingerprint fingerprint
                in

                if distance < !min_distance then begin
                  min_distance := distance;
                  current_bin := bin
                end)
              bins;

            if !min_distance < threshold then
              (!current_bin).domains <-
                url :: (!current_bin).domains
            else
              Hashtbl.add bins url {
                url;
                fingerprint;
                domains = [url];
              };

            create_bins_i ps
      in

      create_bins_i rest;
      bins
    
      
      