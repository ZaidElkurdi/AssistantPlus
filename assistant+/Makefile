include theos/makefiles/common.mk

export ARCHS = armv7s arm64
export TARGET = iphone:latest:8.1
export SDKVERSION=8.1

TWEAK_NAME = Assistant+

Assistant+_FILES = AssistantHooks.xm assistantpluspluginmanager/APSession.xm

Assistant+_FRAMEWORKS = Foundation UIKit CoreFoundation Accounts CoreLocation
Assistant+_PRIVATE_FRAMEWORKS = AssistantServices SAObjects AppSupport
Assistant+_LIBRARIES=substrate objcipc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += assistantpluspluginmanager
SUBPROJECTS += aplocationdaemon
include $(THEOS_MAKE_PATH)/aggregate.mk
