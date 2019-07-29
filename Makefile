TARGET = iphone:11.2:10.0
DEBUG = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = yrudid
yrudid_FILES = Tweak.xm
yrudid_FRAMEWORKS = Foundation
yrudid_PRIVATE_FRAMEWORKS = ManagedConfiguration

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 profiled"

# after-install::
# 	install.exec "killall -9 profiled"
