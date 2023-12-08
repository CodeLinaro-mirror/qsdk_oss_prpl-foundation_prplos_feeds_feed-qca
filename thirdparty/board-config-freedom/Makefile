include $(TOPDIR)/rules.mk

PKG_NAME:=board-config-freedom
PKG_VERSION:=0.0.1
PKG_RELEASE:=1
PKG_LICENSE:=BSD-2-Clause-Patent

include $(INCLUDE_DIR)/package.mk

define Package/board-config-freedom
  TITLE:=Freedom board configuration
  CATEGORY:=Purple
  DEPENDS:=@TARGET_ipq95xx_generic_DEVICE_prpl_freedom
endef

define Package/board-config-freedom/description
 This package contains Freedom board configuration files.
endef

define Build/Compile
endef

define Package/board-config-freedom/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,board-config-freedom))
