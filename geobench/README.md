# geobench
These are D, Rust, and Nim implementations (performed in that order)
of a benchmark of MaxMindDB readers written in the respective
languages. The benchmark's not that serious: the D library looks to be
abandoned and can't be compiled as is on current releases (it needs an
~import std.bitmanip~); the Nim library's written by me and all of
unpolished and very new and blocked on experimental features.

The benchmark requires a copy of GeoLite2-Country.mmdb from maxmind.com

## debug compile times

| Speed | Language | Real | User  | MaxRSS |
|-------|----------|------|-------|--------|
| 1x    | Nim      | 1.1s | 2.18s | 62.8M  |
| 2.1x  | D        | 2.3s | 1.88s | 687M   |
| 9.1x  | Rust     | 10s  | 27.2s | 353M   |

## release compile times

| Speed | Language | Real | User  | MaxRSS |
|-------|----------|------|-------|--------|
| 1x    | Nim      | 2.3s | 4.1s  | 68.9M  |
| 2.4x  | D        | 5.5s | 5.90s | 657M   |
| 8.3x  | Rust     | 19s  | 89.4s | 383M   |

## debug runtimes

| Speed | Language | Real  | User  | MaxRSS |
|-------|----------|-------|-------|--------|
| 1x    | D        | 1.5s  | 1.62s | 7.00M  |
| 2x    | Rust     | 2.93s | 2.92s | 5.88M  |
| 8x    | Nim      | 12s   | 12.1s | 16.7M  |

## release runtimes

| Speed | Language | Real | User  | MaxRSS |
|-------|----------|------|-------|--------|
| 1x    | Rust     | 0.2s | 0.20s | 5.73M  |
| 5x    | D        | 1.0s | 1.18s | 6.63M  |
| 15.5x | Nim      | 3.1s | 3.10s | 16.2M  |
