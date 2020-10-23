# pwcheck
These are D, Rust, and Nim implementations (performed in that order) of a
program inteded to look for extremely weak passwords in Unix systems, not via
brute force but from the inside, reading the system's password hashes and
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
| 1x    | D        | 1.8s | 1.52s | 565M   |
| 1.1x  | Nim      | 2.0s | 6.06s | 110M   |
| 5.4x  | Rust     | 9.7s | 54.2s | 474M   |

## release compile times

| Speed | Language | Real | User  | MaxRSS |
|-------|----------|------|-------|--------|
| 1x    | Nim      | 3.6s | 14s   | 106M   |
| 1.5x  | D        | 5.5s | 5.20s | 591M   |
| 6.4x  | Rust     | 23s  | 161s  | 370M   |

## odd notes
It was only when I wanted to benchmark these with random data that I
discovered that crypt() returns NULL on an invalid hash. Both D and
Rust versions promptly segfaulted. In Nim a NULL (nil) cstring is
unequal to any cstring but another NULL one, so it was fine.

I received a test error once from Rust that I believe was due to the use of a
thread-unsafe crypt() and threaded unit testing.

## runtime performance?
They're identical. crypt() is deliberately slow so it absolutely dominates the
runtime, and every bit of effort spent on avoiding unnecessary copies,
unnecessary recompilation of regex, and so on, was completely wasted.
