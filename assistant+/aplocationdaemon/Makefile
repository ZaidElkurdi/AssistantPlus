ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:8.0

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TOOL_NAME = APLocationDaemon
APLocationDaemon_CFLAGS = -fobjc-arc
APLocationDaemon_FILES = main.mm APLocationManager.m
APLocationDaemon_FRAMEWORKS = Foundation CoreLocation
APLocationDaemon_PRIVATE_FRAMEWORKS = AppSupport
APLocationDaemon_LIBRARIES = objcipc substrate
APLocationDaemon_CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/tool.mk

after-APLocationDaemon-stage::
	$(ECHO_NOTHING)$(FAKEROOT) chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/com.zaid.aplocationdaemon.plist$(ECHO_END)