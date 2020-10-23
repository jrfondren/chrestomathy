T=/usr/bin/time

debug:: clean
	( cd nim; $T nimble build -f )
	( cd d; $T dub build -f )
	( cd rust; $T cargo build )

release:: clean
	( cd nim; $T nimble build -d:release -f )
	( cd d; $T dub build -brelease -f )
	( cd rust; $T cargo build --release )

rebuild::
	rm -fv nim/pwcheck d/pwcheck rust/target/{release,debug}/pwcheck
	( cd nim; $T nimble build )
	( cd d; $T dub build -brelease )
	( cd rust; $T cargo build --release )

clean::
	rm -fv nim/pwcheck d/pwcheck spam.out
	rm -rf d/.dub rust/target

depclean::
	rm -rf ~/.nimble/pkgs/ ~/.dub/packages/ ~/.cargo/registry/

spam.out: spamgen.nim
	nim r -d:release spamgen

bench: spam.out
	$T nim/pwcheck --25 --file spam.out
	$T d/pwcheck --25 --file spam.out
	$T rust/target/release/pwcheck --25 --file spam.out
