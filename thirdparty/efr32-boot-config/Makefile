include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=efr32-boot-config
PKG_RELEASE:=1
PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/efr32-boot-config
  TITLE:=Bootmode configuration for EFR32
  CATEGORY:=prpl Foundation
  SUBMENU:=Utilities
  DEPENDS:=@TARGET_ipq95xx_generic_DEVICE_prpl_freedom
endef

define Package/efr32-boot-config/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/efr32-boot-config.init $(1)/etc/init.d/efr32-boot-config
endef

$(eval $(call BuildPackage,efr32-boot-config))
