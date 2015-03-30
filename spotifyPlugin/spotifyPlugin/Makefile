include theos/makefiles/common.mk
export THEOS_DEVICE_IP=192.168.1.17

export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:8.0
export SDKVERSION=8.2

BUNDLE_NAME = spotifySiri
spotifySiri_BUNDLE_EXTENSION = assistantPlugin
spotifySiri_FILES = $(wildcard *.m) $(wildcard AFNetworking/*.m)
spotifySiri_INSTALL_PATH = /Library/AssistantPlusPlugins/
spotifySiri_CFLAGS = -fobjc-arc
spotifySiri_FRAMEWORKS = MobileCoreServices Foundation SystemConfiguration UIKit CoreGraphics Security

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
