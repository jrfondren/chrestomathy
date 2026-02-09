T=/usr/bin/time

debug:: clean
	( cd nim; $T nimble build -f )
	( cd d; $T dub build -f )
	( cd rust; $T cargo build )
	( cd ocaml; $T dune build )
	( cd v; $T v pwcheck.v )

release:: clean
	( cd nim; $T nimble build -d:release -f )
	( cd d; $T dub build -brelease -f )
	( cd rust; $T cargo build --release )
	( cd ocaml; $T dune build --release )
	( cd v; $T v -prod pwcheck.v )

rebuild::
	rm -fv nim/pwcheck d/pwcheck rust/target/{release,debug}/pwcheck
	( cd nim; $T nimble build )
	( cd d; $T dub build -brelease )
	( cd rust; $T cargo build --release )
	( cd ocaml; $T dune build --release )
	( cd v; $T v -prod pwcheck.v )

clean::
	rm -fv nim/pwcheck d/pwcheck v/pwcheck spam.out
	rm -rf d/.dub rust/target ocaml/_build

spam.out: spamgen.nim
	nim r -d:release spamgen

bench:: spam.out
	$T nim/pwcheck --25 --file spam.out
	$T d/pwcheck --25 --file spam.out
	$T rust/target/release/pwcheck --25 --file spam.out
	$T ocaml/_build/default/bin/main.exe --25 --file spam.out
	$T v/pwcheck --25 --file=spam.out
