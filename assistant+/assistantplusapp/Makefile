include theos/makefiles/common.mk

export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:8.4
export SDKVERSION=8.4

APPLICATION_NAME = AssistantPlusApp
AssistantPlusApp_FILES = $(wildcard *.m)
AssistantPlusApp_FRAMEWORKS = UIKit CoreGraphics QuartzCore Spotify
AssistantPlusApp_PRIVATE_FRAMEWORKS = AppSupport
AssistantPlusApp_CFLAGS = -fobjc-arc
AssistantPlusApp_LDFLAGS = -F /opt/theos/include

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard"
