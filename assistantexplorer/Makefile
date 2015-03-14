include theos/makefiles/common.mk

GO_EASY_ON_ME = 1

export ARCHS = armv7s arm64
export TARGET = iphone:latest:8.1
export SDKVERSION=8.1

# use CLANG
TARGET_CC = xcrun --sdk iphoneos clang
TARGET_CXX = xcrun --sdk iphoneos clang++

TWEAK_NAME= AssistantExplorer
AssistantExplorer_FILES = Tweak.xm AssistantMusicController.xm AssistantQueryHandler.m AssistantQueryParser.m AssistantAceCommandBuilder.xm HelloSnippetViewController.xm
AssistantExplorer_FRAMEWORKS = Foundation UIKit CoreFoundation Accounts CoreLocation
AssistantExplorer_PRIVATE_FRAMEWORKS = AssistantServices SAObjects

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
