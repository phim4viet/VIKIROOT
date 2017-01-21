
ARCH := $(shell adb shell getprop ro.product.cpu.abi)
SDK_VERSION := $(shell adb shell getprop ro.build.version.sdk)

AS := $(ANDROID_NDK_HOME)/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-as
OC := $(ANDROID_NDK_HOME)/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-objcopy

all: build

build: payload.h
	ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk APP_ABI=$(ARCH) APP_PLATFORM=android-$(SDK_VERSION)

push: build
	adb push libs/$(ARCH)/vikiroot /data/local/tmp/vikiroot

payload.h: payload
	xxd -i $^ $@

payload.o: payload.s
	$(AS) -o $@ $^

payload: payload.o
	$(OC) -O binary $^ $@

root: push
	adb shell 'chmod 777 /data/local/tmp/vikiroot'
	adb shell '/data/local/tmp/vikiroot 1337'

clean:
	rm -rf libs
	rm -rf obj
	rm -rf payload.h
	rm -rf payload.o
	rm -rf payload

