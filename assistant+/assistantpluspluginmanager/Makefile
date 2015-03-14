include theos/makefiles/common.mk

TWEAK_NAME = AssistantPlusPluginManager
AssistantPlusPluginManager_FILES = Tweak.xm APSession.xm APPluginManager.mm APPlugin.m
AssistantPlusPluginManager_LIBRARIES=substrate objcipc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
