LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	exploit.c

LOCAL_MODULE := vikiroot
LOCAL_LDFLAGS   += -llog
LOCAL_CFLAGS    += -DDEBUG

include $(BUILD_EXECUTABLE)

