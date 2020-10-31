import std/[random, strformat]

const target = 1 * 1024 * 1024
var wrote = 0

randomize()

let f = open("spam.out", fmWrite)
while wrote < target:
  # deliberately including invalid IPs
  let s = &"{rand(300)}.{rand(300)}.{rand(300)}.{rand(300)}"
  f.writeLine s
  wrote.inc s.len + 1
