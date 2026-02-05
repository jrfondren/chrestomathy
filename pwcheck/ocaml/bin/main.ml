open Pwcheck

let lint user = function
  | Safe -> ()
  | Blank -> Printf.printf "%s lacks a password! This is dangerous!\n" user
  | DES ->
    Printf.printf "%s has an old DES-style password hash! This is dangerous!\n"
      user
  | WeakDES pass ->
    Printf.printf "%s has a weak (DES!) password of: %s\n" user pass
  | Weak pass -> Printf.printf "%s has a weak password of: %s\n" user pass
  | Erroneous -> ()

let usage_line = "<--25|--500> --file=HASHFILE"

let usage msg =
  Printf.eprintf "%susage: %s %s\n" msg Sys.argv.(0) usage_line;
  exit 1

let known, mode =
  let known = ref None in
  let mode = ref `Shadow in
  try
    Arg.parse_argv Sys.argv
      [
        ( "--25",
          Arg.Unit (fun () -> known := Some Known.top25),
          "Use the 'top 25' password list" );
        ( "--500",
          Arg.Unit (fun () -> known := Some Known.top500),
          "Use the 'top 500 password list" );
        ( "--file",
          Arg.String (fun path -> mode := `Hashfile path),
          "Check a file with one hash per line, instead of /etc/shadow" );
      ]
      (fun a -> usage ("unhangled arg " ^ a ^ "\n"))
      ("pwcheck " ^ usage_line);
    match !known with
    | Some a -> a, !mode
    | None -> usage "No passwords to look for. Try passing --25 or --500\n"
  with Arg.Bad msg ->
    prerr_endline msg;
    exit 1

let () =
  match mode with
  | `Shadow ->
    In_channel.with_open_text "/etc/shadow" (fun file ->
        In_channel.fold_lines
          (fun () line ->
            match String.split_on_char ':' line with
            | user :: hash :: _ -> lint user (is_weak known hash)
            | _ -> ())
          () file)
  | `Hashfile path ->
    In_channel.with_open_text path (fun file ->
        In_channel.fold_lines
          (fun () line -> lint path (is_weak known line))
          () file)
