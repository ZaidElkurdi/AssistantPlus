include theos/makefiles/common.mk

export GO_EASY_ON_ME=1
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 8.0

TWEAK_NAME = AssistantPlusPluginManager
AssistantPlusPluginManager_CFLAGS = -fobjc-arc
AssistantPlusPluginManager_FILES = Tweak.xm APPluginSystem.m APPlugin.m APSpringboardUtils.m APActivatorListener.m
AssistantPlusPluginManager_PRIVATE_FRAMEWORKS = AssistantServices SAObjects AppSupport
AssistantPlusPluginManager_FRAMEWORKS = Foundation UIKit CoreLocation
AssistantPlusPluginManager_LIBRARIES = substrate activator
AssistantPlusPluginManager_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
