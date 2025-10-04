include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=wireless-freedom
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/wireless-freedom
  SUBMENU:=ath12k Board-Specific Overrides
  SECTION:=freedom
  CATEGORY:=uci
  TITLE:=Freedom wireless UCI extension
endef

define Package/wireless-freedom/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/wireless-ext-freedom $(1)/etc/uci-defaults/50-wireless-ext-freedom

ifeq ($(CONFIG_PRPL_CPE_OPMODE_GATEWAY),y)
	$(INSTALL_BIN) ./files/wireless-freedom $(1)/etc/uci-defaults/10-wireless-freedom
endif

ifeq ($(CONFIG_PRPL_CPE_OPMODE_EXTENDER),y)
	$(INSTALL_BIN) ./files/wireless-freedom.extender $(1)/etc/uci-defaults/10-wireless-freedom
endif

endef

$(eval $(call BuildPackage,wireless-freedom))
