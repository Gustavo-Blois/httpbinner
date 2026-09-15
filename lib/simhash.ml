let tokenize s =
  String.split_on_char ' ' s |> List.filter ((<>) "") |> List.map String.trim |>  List.filter ((<>) "")

let simhash tokens =
  let hash_bits = 64 in
  let counts = Array.make hash_bits 0 in
  List.iter
    (fun t ->
      let h = Sha1.string t |> Sha1.to_hex |> Z.of_string_base 16 in
      for i = 0 to hash_bits - 1 do
        if Z.testbit h i then counts.(i) <- counts.(i) + 1
        else counts.(i) <- counts.(i) - 1
      done)
    tokens;
  let fingerprint = ref 0L in
  for i = 0 to hash_bits - 1 do
    if counts.(i) >= 0 then
      fingerprint := Int64.logor !fingerprint (Int64.shift_left 1L i)
  done;
  !fingerprint

let bit_count_fast (n : int64) : int64 =
  let rec helper acc num =
    if Int64.equal num 0L then acc
    else helper (Int64.succ acc) (Int64.logand num (Int64.pred num))
  in
  helper 0L n

let hamming_distance x y = bit_count_fast (Int64.logxor x y)
  
let distance_between_texts distance x y = 
  distance (simhash x) (simhash y) 