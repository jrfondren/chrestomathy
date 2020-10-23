import std/[re, osproc, strformat, strutils]

type
  Weaknesses = enum
    Ok, NoPass, DES, DESPass, WeakPass
  Weakness = object
    case kind: Weaknesses
    of DESPass, WeakPass:
      pass: string
    else: discard

proc `==`(a, b: Weakness): bool =
  if a.kind != b.kind: return false
  case a.kind
  of Ok, NoPass, DES: return true
  of DESPass, WeakPass: return a.pass == b.pass

proc crypt(phrase, salt: cstring): cstring
  {.cdecl, importc, dynlib: "libcrypt.so".}

const
  weak25 = readFile("assets/top25.list").strip(chars = Newlines).splitLines
  weak500 = readFile("assets/top500.list").strip(chars = Newlines).splitLines
let
  hashre = re"(^[$](?:1|2a|5|6)[$][^$]+[$])"
  shadowre = re"^([^:]+):([^:]+):"
  hostname = execProcess("/usr/bin/hostname", options = {}).strip
var
  weak: seq[string]

proc isWeak(hash: string): Weakness =
  var matches: array[0..0, string]
  # man 5 shadow
  if hash == "*": return Weakness(kind: Ok)
  elif hash == "": return Weakness(kind: NoPass)
  elif hash[0] == '!': return Weakness(kind: Ok)
  # man 3 crypt
  elif hash.contains(hashre, matches):
    for pass in weak:
      if hash == crypt(pass, matches[0]):
        return Weakness(kind: WeakPass, pass: pass)
    return Weakness(kind: Ok)
  elif hash.len >= 2:
    let salt = hash[0 ..< 2]
    for pass in weak:
      if hash == crypt(pass, salt):
        return Weakness(kind: DESPass, pass: pass)
    return Weakness(kind: DES)
  else:
    return Weakness(kind: Ok)

when defined(unittests):
  import unittest
  weak = weak25
  suite "isWeak":
    test "password is password":
      check(isWeak("$1$YzTLPnhJ$OZoHkjAYlIgCmOKQi.PXn.") == Weakness(
          kind: WeakPass, pass: "password"))
    test "password is ok":
      check(isWeak("$1$YzTLPnhJ$mvaycoMIyVr/NaEHKzB5H0") == Weakness(kind: Ok))
    test "account is locked":
      check(isWeak("!foo") == Weakness(kind: Ok))
    test "account login is disabled":
      check(isWeak("*") == Weakness(kind: Ok))
    test "account lacks a password":
      check(isWeak("") == Weakness(kind: NoPass))
    test "account has DES hash":
      check(isWeak("foo") == Weakness(kind: DES))
    test "password is monkey (DES)":
      check(isWeak("lhBnWgIh1qed6") == Weakness(kind: DESPass, pass: "monkey"))

proc lint(user, hash: string) =
  let weak = isWeak(hash)
  case weak.kind
  of WeakPass: echo &"{user} has a weak password of: {weak.pass}"
  of DESPass: echo &"{user} has a weak (DES!) password of: {weak.pass}"
  of Ok: discard
  of NoPass: echo &"{user} lacks a password! This is dangerous!"
  of DES: echo &"{user} has an old DES-style password hash! This is dangerous!"

proc main(`25` = false, `500` = false, file = "") =
  if `25`: weak &= weak25
  if `500`: weak &= weak500
  if weak.len == 0: quit "No passwords to look for. Try passing --25 or --500"
  if file != "":
    for hash in file.lines:
      lint(file, hash)
  else:
    var matches: array[0..1, string]
    for line in "/etc/shadow".lines:
      if line.contains(shadowre, matches):
        lint(matches[0], matches[1])

when isMainModule and not defined(unittests):
  import cligen
  dispatch(main, short = {"25": '\0', "500": '\0'}, help = {
    "25": "Use the 'top 25' password list",
    "500": "Use the 'top 500' password list",
    "file": "Check a file with one hash per line, instead of /etc/shadow",
  })
