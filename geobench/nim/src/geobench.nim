import std/tables
import maxminddb, maxminddb/node
import iputils

let database = "GeoLite2-Country.mmdb"
  .readFile
  .initMaxMind

var n: int
for line in stdin.lines:
  if isIPv4(line):
    let res = database.lookup(line.parseIPv4)
    if res != nil and "country" in res.mapData:
      n.inc res.mapGet[:Table[string, Node]]("country")["iso_code"].get[:string].len
echo n
