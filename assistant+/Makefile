include theos/makefiles/common.mk

export ARCHS = armv7s arm64
export TARGET = iphone:clang:latest:8.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 8.0
export SDKVERSION=8.1

TWEAK_NAME = Assistant+

Assistant+_FILES = AssistantHooks.xm assistantpluspluginmanager/APSession.xm assistantpluspluginmanager/APPluginSnippetViewController.xm

Assistant+_FRAMEWORKS = Foundation UIKit CoreFoundation Accounts CoreLocation
Assistant+_PRIVATE_FRAMEWORKS = AssistantServices SAObjects AppSupport
Assistant+_LIBRARIES=substrate
Assistant+_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	chmod u+s $(THEOS_STAGING_DIR)/Applications/AssistantPlusApp.app/assistantplus_root_helper

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += assistantpluspluginmanager
SUBPROJECTS += aplocationdaemon
SUBPROJECTS += assistantplusapp
SUBPROJECTS += assistantplus_root_helper
SUBPROJECTS += customreply

include $(THEOS_MAKE_PATH)/aggregate.mk
