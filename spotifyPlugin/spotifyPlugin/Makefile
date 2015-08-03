include theos/makefiles/common.mk

export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:8.4
export SDKVERSION=8.4

BUNDLE_NAME = spotifySiri
spotifySiri_BUNDLE_EXTENSION = assistantPlugin
spotifySiri_FILES = $(wildcard *.m) $(wildcard Util/*/*.m) $(wildcard Util/*.m)
spotifySiri_INSTALL_PATH = /Library/AssistantPlusPlugins/
spotifySiri_CFLAGS = -fobjc-arc
spotifySiri_FRAMEWORKS = MobileCoreServices Foundation SystemConfiguration UIKit CoreGraphics Security Spotify AudioToolbox AVFoundation
spotifySiri_LDFLAGS = -F /opt/theos/include

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
