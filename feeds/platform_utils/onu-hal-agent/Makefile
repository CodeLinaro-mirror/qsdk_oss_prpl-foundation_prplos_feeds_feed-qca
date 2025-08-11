include $(TOPDIR)/rules.mk

PKG_NAME:=onu-hal-agent
PKG_LICENSE:=ISC
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.openwrt.24.0.r29
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/fontana/middleware/onu-hal
PKG_MIRROR_HASH:=skip
PKG_VERSION:=55d6c893c81274bf68ee1f69e3cf8ff27a04393b

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ipq gpon HAL
  DEPENDS:=+libubus +libubox
endef

define Package/$(PKG_NAME)/description
	ipq xpon module
endef

define Package/$(PKG_NAME)-mock/description
	ipq xpon module
endef

TARGET_LDFLAGS += -L$(STAGING_DIR) \
		  -lubox -lubus

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/onu_hal_agent $(1)/usr/bin/onu_hal_agent
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
