include theos/makefiles/common.mk
export THEOS_DEVICE_IP=192.168.1.17

export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:8.0
export SDKVERSION=8.2

BUNDLE_NAME = customreply
customreply_BUNDLE_EXTENSION = assistantPlugin
customreply_FILES = customReplyCommands.m customreply.m
customreply_INSTALL_PATH = /Library/AssistantPlusPlugins/
customreply_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
