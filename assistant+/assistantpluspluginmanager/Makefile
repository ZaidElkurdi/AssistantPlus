include theos/makefiles/common.mk

GO_EASY_ON_ME=1

TWEAK_NAME = AssistantPlusPluginManager
AssistantPlusPluginManager_CFLAGS = -fobjc-arc
AssistantPlusPluginManager_FILES = Tweak.xm APPluginManager.mm APPlugin.m APPluginSnippetViewController.xm APSpringboardUtils.m
AssistantPlusPluginManager_PRIVATE_FRAMEWORKS = AssistantServices SAObjects AppSupport
AssistantPlusPluginManager_FRAMEWORKS = Foundation UIKit CoreLocation
AssistantPlusPluginManager_LIBRARIES=substrate objcipc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"