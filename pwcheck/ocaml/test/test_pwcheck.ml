let weakness = Alcotest.testable Pwcheck.pp_weakness ( = )

let test name v hash =
  Alcotest.test_case name `Quick (fun () ->
      Alcotest.check weakness "" v Pwcheck.(is_weak Known.top25 hash))

let safe =
  let open Pwcheck in
  [
    test "unknown" Safe "$1$YzTLPnhJ$mvaycoMIyVr/NaEHKzB5H0";
    test "locked" Safe "!foo";
    test "disabled" Safe "*";
  ]

let unsafe =
  let open Pwcheck in
  [
    test "is blank" Blank "";
    test "is password" (Weak "password") "$1$YzTLPnhJ$OZoHkjAYlIgCmOKQi.PXn.";
    test "is monkey (DES)" (WeakDES "monkey") "lhBnWgIh1qed6";
    test "is DES?" DES "foo";
  ]

let () = Alcotest.run "Pwcheck" ["safe hashes", safe; "unsafe hashes", unsafe]
