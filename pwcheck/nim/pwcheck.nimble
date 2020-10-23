# Package

version       = "0.1.0"
author        = "Julian Fondren"
description   = "Check a Unix system for weak /etc/shadow passwords"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["pwcheck"]


# Dependencies

requires "nim >= 1.4.0"
requires "cligen >= 1.2.2"

import distros
foreignDep "crypt"

task test, "Run inline tests":
  selfExec "r -d:unittests src/pwcheck || true"
