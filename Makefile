Default: BuildRust CopyRust

all: BuildRust CopyRust BuildHap

BuildRust:
	$(MAKE) -C daisy_native

CopyRust:
	rsync -av --exclude oh-package.json5 daisy_native/dist/ entry/libs/

BuildHap:
	hvigorw assembleApp --mode project -p product=default -p buildMode=debug --no-daemon
