open Httpbinner

let check_tokenize name expected input =
  Alcotest.(check (list string)) name expected (Request.tokenize input)

let check_simhash name expected input =
  Alcotest.(check int64) name expected (Simhash.simhash input)

let check_distance name expected (x, y) =
  Alcotest.(check int64) name expected
    (Simhash.distance_between_texts Simhash.hamming_distance x y)

let fox = [ "the"; "quick"; "brown"; "fox" ]
let dog = [ "the"; "quick"; "brown"; "dog" ]

let tokenize_spaces () =
  check_tokenize "spaces and newline" fox "the quick \n  brown fox"

let simhash_fox () = check_simhash "fox" 0xd767e7f615fbfefeL fox
let simhash_dog () = check_simhash "dog" 0xdd45f7ef15fbfeeeL dog
let distance_fox_dog () = check_distance "fox vs dog" 9L (fox, dog)
let distance_identicos () = check_distance "fox vs fox" 0L (fox, fox)

let () =
  Alcotest.run "httpbinner"
    [ ( "tokenize",
        [ Alcotest.test_case "spaces" `Quick tokenize_spaces ] );
      ( "simhash",
        [ Alcotest.test_case "fox" `Quick simhash_fox;
          Alcotest.test_case "dog" `Quick simhash_dog ] );
      ( "distance",
        [ Alcotest.test_case "fox vs dog" `Quick distance_fox_dog;
          Alcotest.test_case "the same text" `Quick distance_identicos ] ) ]