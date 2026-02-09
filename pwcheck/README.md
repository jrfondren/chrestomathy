# pwcheck
These are D, Rust, Nim, OCaml, and V implementations (performed in that order)
of a program intended to look for extremely weak passwords in Unix systems, not
via brute force but from the inside, reading the system's password hashes and
calling crypt() appropriately against the list of passwords.

These were sincere efforts at solving a practical problem, not just created for
a benchmark or to make one language look better than the others. The D and Rust
versions have been distorted slightly by lazier changes after the fact (of D,
to add the top500 list; of D and Rust, to add the --file argument for testing).

So the code is really what's to be compared here; some numbers are just
provided for fun.

## debug compile times

| Speed | Language | Real | User  | MaxRSS |
|-------|----------|------|-------|--------|
| 0.4x  | V        | 0.2s | 0.22s | 80.3M  |
| 1x    | OCaml    | 0.4s | 0.39s | 48.8M  |
| 1.4x  | Nim      | 0.7s | 0.69s | 132M   |
| 1.8x  | D        | 1.3s | 1.04s | 435M   |
| 15x   | Rust     | 2.5s | 8.50s | 303M   |

## release compile times

| Speed | Language | Real | User  | MaxRSS |
|-------|----------|------|-------|--------|
| 1x    | OCaml    | 0.4s | 0.24s | 39.9M  |
| 2.3x  | Nim      | 7.8s | 0.69s | 131M   |
| 8.7x  | D        | 3.3s | 3.11s | 411M   |
| 11x   | V        | 5.7s | 4.43s | 80.3M  |
| 76x   | Rust     | 3.3s | 26.9s | 349M   |

## odd notes
It was only when I wanted to benchmark these with random data that I
discovered that crypt() returns NULL on an invalid hash. Both D and
Rust versions promptly segfaulted. In Nim a NULL (nil) cstring is
unequal to any cstring but another NULL one, so it was fine. The OCaml
library raised `Failure("crypt_r: fail to hash the key")`

I received a test error once from Rust that I believe was due to the use of a
thread-unsafe crypt() and threaded unit testing.

## runtime performance?
They're identical. crypt() is deliberately slow so it absolutely dominates the
runtime, and every bit of effort spent on avoiding unnecessary copies,
unnecessary recompilation of regex, and so on, was completely wasted.

In detailed performance stats, Nim and Rust use 2/3 the memory of OCaml while
D uses 4/3. Vs. OCaml, other implementations get +32% to +65% the number of branch
misses, and +47% to +83% the number of cache references. Nim (-7%) and Rust
(-26%) do better on cache misses, while V does worse (+45%) and D (+153%) falls
on its face.
