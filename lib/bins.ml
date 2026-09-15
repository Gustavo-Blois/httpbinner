open Simhash
type bin = {
  url: string;
  fingerprint: int64;
  mutable domains: string list;
}

let create_bins url_and_tokens_list threshold =
  let (url,tokens) = List.hd url_and_tokens_list in
  let first_fingerprint = simhash tokens in
  let first_bin = {url;fingerprint=first_fingerprint;domains=[url]} in
  let bins = ref [first_bin] in
  let rec create_bins_i = function
    | [] -> 
    | (url,tokens)::ps ->
      let fingerprint = simhash tokens in
      let min_distance = ref Int64.max_int in
      let current_bin = ref {url="";fingerprint=0;domains=[]} in
      List.iter (fun bin -> 
        let distance = distance_between_texts hamming_distance bin.fingerprint fingerprint in
        if distance < min_distance
          then min_distance := distance;
          current_bin := bin
        else ()
      ) bins;
      if min_distance < threshold then
    
        (* To-Do: Make  bins an array, so we can store a reference to the array position at current_bin
        then it will be easier to merge domains into a bin
        *)
      
      