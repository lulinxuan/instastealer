include theos/makefiles/common.mk
TWEAK_NAME = InstaStealer
InstaStealer_FILES = Tweak.xm
InstaStealer_FRAMEWORKS = UIKit AssetsLibrary


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
