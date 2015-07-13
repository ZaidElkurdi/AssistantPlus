include theos/makefiles/common.mk

export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:8.4
export SDKVERSION=8.4

APPLICATION_NAME = AssistantPlusApp
AssistantPlusApp_FILES = main.m AppDelegate.m MainViewController.m APActivatorListener.m ActivatorListenersViewController.m ListenerDetailViewController.m CustomReplyDetailViewController.m CustomRepliesViewController.m APCustomReply.m PluginsViewController.m CaptureGroupCommandDetailViewController.m CaptureGroupCommandsViewController.m APCaptureGroupCommand.m
AssistantPlusApp_FRAMEWORKS = UIKit CoreGraphics QuartzCore
AssistantPlusApp_PRIVATE_FRAMEWORKS = AppSupport
AssistantPlusApp_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard"