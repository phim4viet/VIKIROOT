#TOOLCHAIN := $(ANDROID_NDK_HOME)/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin/
#SYSROOT := $(ANDROID_NDK_HOME)/platforms/android-24/arch-arm64/
#PREFIX := $(TOOLCHAIN)aarch64-linux-android-

TOOLCHAIN := $(ANDROID_NDK_HOME)/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/
SYSROOT := $(ANDROID_NDK_HOME)/platforms/android-24/arch-arm/
PREFIX := $(TOOLCHAIN)arm-linux-androideabi-

CFLAGS := -Os -fPIE -Wall --sysroot=$(SYSROOT)
LDFLAGS := -pthread -s -pie -Wall --sysroot=$(SYSROOT)
CC := $(PREFIX)gcc
AS := $(PREFIX)as
OC := $(PREFIX)objcopy
OJ := $(PREFIX)objdump

debug: CFLAGS += -DDBG
debug: all

all: exploit

exploit: exploit.o
	$(CC) -o $@ $^ $(LDFLAGS)

exploit.o: exploit.c payload.h
	$(CC) -o $@ -c $< $(CFLAGS)

payload.h: payload
	xxd -i $^ $@

payload.o: payload.s
	$(AS) -o $@ $^

payload: payload.o
	$(OC) -O binary $^ $@

clean:
	rm -f *.o *.h payload exploit
