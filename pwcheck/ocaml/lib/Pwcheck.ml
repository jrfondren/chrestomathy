module Known = Known

type weakness =
  | Safe
  | Blank
  | DES
  | WeakDES of string
  | Weak of string
  | Erroneous

let pp_weakness fmt = function
  | Safe -> Format.fprintf fmt "Safe"
  | Blank -> Format.fprintf fmt "Blank"
  | DES -> Format.fprintf fmt "DES"
  | WeakDES s -> Format.fprintf fmt "(WeakDES %S)" s
  | Weak s -> Format.fprintf fmt "(Weak %S)" s
  | Erroneous -> Format.fprintf fmt "Erroneous"

let hash_re = Re.compile (Re.Pcre.re {|^[$](?:1|2a|5|6)[$][^$]+[$]|})

let is_weak known = function
  | "*" -> Safe
  | "" -> Blank
  | s when s.[0] = '!' -> Safe
  | s when String.length s < 3 -> Erroneous
  | hash -> (
    let salt, des =
      match Re.exec hash_re hash with
      | group -> Re.Group.get group 0, false
      | exception Not_found -> String.sub hash 0 2, true
    in
    match
      Array.find_opt (fun pass -> hash = Crypt.crypt ~salt pass) known, des
    with
    | Some pass, true -> WeakDES pass
    | Some pass, false -> Weak pass
    | None, true -> DES
    | None, false -> Safe
    | exception Failure _ -> Erroneous)
