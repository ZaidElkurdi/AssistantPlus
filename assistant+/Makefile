include theos/makefiles/common.mk

export ARCHS = armv7s arm64
export TARGET = iphone:latest:8.1
export SDKVERSION=8.1

TWEAK_NAME = Assistant+

Assistant+_FILES = AssistantHooks.xm APSession.xm APPluginManager.mm APPlugin.m
Assistant+_FRAMEWORKS = Foundation UIKit CoreFoundation Accounts CoreLocation
Assistant+_PRIVATE_FRAMEWORKS = AssistantServices SAObjects
Assistant+_CODESIGN_FLAGS = -SEntitlements.plist

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
