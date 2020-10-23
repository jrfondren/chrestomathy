import std/random

const
  target = 10 * 1024
  hashes = ["1", "2a", "5", "6"]
var
  wrote = 0

proc randlet: char = char('a'.byte + rand(25).byte)

randomize()

let f = open("spam.out", fmWrite)
while wrote < target:
  var s = '$' & sample(hashes) & '$'
  for _ in 1..6: s &= randlet()
  s &= '$'
  for _ in 0 .. rand(10..48): s &= randlet()
  f.writeLine s
  wrote.inc s.len + 1
f.writeLine "$1$YzTLPnhJ$OZoHkjAYlIgCmOKQi.PXn."
f.writeLine "lhBnWgIh1qed6"
