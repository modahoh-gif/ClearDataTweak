TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ClearDataTweak

ClearDataTweak_FILES = Tweak.x
ClearDataTweak_CFLAGS = -fobjc-arc
ClearDataTweak_FRAMEWORKS = UIKit Foundation Security

include $(THEOS_MAKEFILE_PATH)/tweak.mk
