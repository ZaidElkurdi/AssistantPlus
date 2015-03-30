include theos/makefiles/common.mk

export THEOS_DEVICE_IP=192.168.1.17

export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:8.0
export SDKVERSION=8.2

APPLICATION_NAME = AssistantPlusApp
AssistantPlusApp_FILES = main.m AppDelegate.m MainViewController.m APActivatorListener.m ActivatorListenersViewController.m ListenerDetailViewController.m CustomReplyDetailViewController.m CustomRepliesViewController.m APCustomReply.m
AssistantPlusApp_FRAMEWORKS = UIKit CoreGraphics QuartzCore
AssistantPlusApp_PRIVATE_FRAMEWORKS = AppSupport
AssistantPlusApp_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec “uicache”