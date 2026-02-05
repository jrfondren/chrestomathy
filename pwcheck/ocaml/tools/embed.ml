let () =
  match Sys.argv with
  | [|_; name; file|] -> (
    let ic = open_in file in
    Printf.printf "let %s = [|" name;
    try
      while true do
        Printf.printf "  %S;\n" (input_line ic)
      done
    with End_of_file -> print_endline "|]")
  | _ -> raise (Invalid_argument "argv")
