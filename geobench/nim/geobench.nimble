# Package

version       = "0.1.0"
author        = "Julian Fondren"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["geobench"]


# Dependencies

requires "nim >= 1.4.0"
requires "iputils >= 0.2.0"
requires "https://github.com/jrfondren/nim-maxminddb"
