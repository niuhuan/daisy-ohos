# 检测操作系统类型
OS := $(shell uname -s)

ifeq ($(OS), Linux)
	IS_LINUX := true
else
    IS_LINUX := false
endif

all: BuildRust

BuildRust:
	ohrs build --release -a arm64
ifeq ($(IS_LINUX), true)
	find dist -type f -name "*.so" ! -name "daisy_native" -exec rm -f {} \;
endif
	ohrs artifact
