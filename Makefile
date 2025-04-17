Default: BuildRust

all: BuildRust BuildHap

BuildRust:
	$(MAKE) -C daisy_native

BuildHap:
	hvigorw assembleApp --mode project -p product=default -p buildMode=release --no-daemon
