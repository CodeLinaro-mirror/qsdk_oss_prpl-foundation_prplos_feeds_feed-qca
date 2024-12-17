include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=io-expander-freedom
PKG_RELEASE:=1
PKG_FLAGS:=nonshared
PKG_LICENSE:=BSD-2-Clause-Patent

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/io-expander-freedom
  TITLE:=Freedom board io expander initialization
  CATEGORY:=Purple
  DEPENDS:=@TARGET_ipq95xx_generic_DEVICE_prpl_freedom
endef

define Package/io-expander-freedom/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/io-expander-freedom.init $(1)/etc/init.d/io-expander-freedom
endef

$(eval $(call BuildPackage,io-expander-freedom))
