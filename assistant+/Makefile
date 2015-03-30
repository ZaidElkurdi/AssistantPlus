include theos/makefiles/common.mk

export ARCHS = armv7s arm64
export TARGET = iphone:clang:latest:8.0
export SDKVERSION=8.2

TWEAK_NAME = Assistant+

Assistant+_FILES = AssistantHooks.xm assistantpluspluginmanager/APSession.xm assistantpluspluginmanager/APPluginSnippetViewController.xm

Assistant+_FRAMEWORKS = Foundation UIKit CoreFoundation Accounts CoreLocation
Assistant+_PRIVATE_FRAMEWORKS = AssistantServices SAObjects AppSupport
Assistant+_LIBRARIES=substrate
Assistant+_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += assistantpluspluginmanager
SUBPROJECTS += aplocationdaemon
SUBPROJECTS += assistantplusapp

include $(THEOS_MAKE_PATH)/aggregate.mk
