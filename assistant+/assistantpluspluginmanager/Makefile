include theos/makefiles/common.mk

TWEAK_NAME = AssistantPlusPluginManager
AssistantPlusPluginManager_CFLAGS = -fobjc-arc
AssistantPlusPluginManager_FILES = Tweak.xm APPluginSystem.m APPlugin.m APSpringboardUtils.m
AssistantPlusPluginManager_PRIVATE_FRAMEWORKS = AssistantServices SAObjects AppSupport
AssistantPlusPluginManager_FRAMEWORKS = Foundation UIKit CoreLocation
AssistantPlusPluginManager_LIBRARIES = substrate activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
