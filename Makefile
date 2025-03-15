
TestRust: BuildRust CopyRust

BuildRust:
	cd daisy_native && ohrs build --release -a arm64

CopyRust:
	rsync -av --exclude oh-package.json5  daisy_native/dist/ entry/libs/
