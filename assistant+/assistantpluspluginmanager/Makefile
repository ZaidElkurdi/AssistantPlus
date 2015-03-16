include theos/makefiles/common.mk

TWEAK_NAME = AssistantPlusPluginManager
AssistantPlusPluginManager_FILES = Tweak.xm APPluginManager.mm APPlugin.m APPluginSnippetViewController.xm
AssistantPlusPluginManager_PRIVATE_FRAMEWORKS = AssistantServices SAObjects
AssistantPlusPluginManager_FRAMEWORKS = Foundation UIKit CoreLocation
AssistantPlusPluginManager_LIBRARIES=substrate objcipc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"