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
	rm -fv nim/geobench d/geobench rust/target/{release,debug}/geobench
	( cd nim; $T nimble build )
	( cd d; $T dub build -brelease )
	( cd rust; $T cargo build --release )

clean::
	rm -fv nim/geobench d/geobench spam.out
	rm -rf d/.dub rust/target

spam.out: spamgen.nim
	nim r -d:release spamgen

bench: spam.out
	$T nim/geobench < spam.out
	$T d/geobench < spam.out
	$T rust/target/release/geobench < spam.out
