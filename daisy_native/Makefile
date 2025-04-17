all: BuildRust

BuildRust:
	ohrs build --release -a arm64
	find dist -type f -name "*.so" ! -name "libdaisy_native.so" -exec rm -f {} \;
	mkdir -p package
	ohrs artifact
