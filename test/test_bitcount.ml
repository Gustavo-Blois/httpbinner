let check name expected input =
  Alcotest.(check int64) name expected (Httpbinner.Simhash.bit_count_fast input)

let standard_cases () =
  check "zero" 0L 0L;
  check "255" 8L 0xFFL

let naive n =
  let c = ref 0L in
  for i = 0 to 63 do
    if Int64.equal (Int64.logand (Int64.shift_right_logical n i) 1L) 1L
    then c := Int64.succ !c
  done;
  !c

let compare_to_reference =
  QCheck.Test.make ~name:"equals to reference" ~count:10_000
    QCheck.int64
    (fun n -> Int64.equal (Httpbinner.Simhash.bit_count_fast n) (naive n))

let () = 
Alcotest.run "bitcount"
["bit_count",
[Alcotest.test_case "standard cases" `Quick standard_cases;
QCheck_alcotest.to_alcotest compare_to_reference
]]