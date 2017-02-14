LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
  exploit.c

LOCAL_CFLAGS += -DDEBUG -D__ARM__ -Wunused
APP_ABI := armeabi armeabi-v7a

LOCAL_MODULE := exploit
LOCAL_MODULE_TAGS := optional
LOCAL_LDFLAGS += -static

include $(BUILD_EXECUTABLE)
