include theos/makefiles/common.mk

export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:8.0
export SDKVERSION=8.1

BUNDLE_NAME = customreply
customreply_BUNDLE_EXTENSION = assistantPlugin
customreply_FILES = customReplyCommands.m customreply.m
customreply_INSTALL_PATH = /Library/AssistantPlusPlugins/
customreply_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
