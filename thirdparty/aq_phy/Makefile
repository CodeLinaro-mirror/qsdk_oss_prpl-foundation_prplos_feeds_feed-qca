include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=aq_phy
PKG_BRANCH:=master
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/aq_phy

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=network
  CATEGORY:=Network
  TITLE:=Aquantia PHY Download
endef

define Package/$(PKG_NAME)/description
  Aquantia PHY Download
endef


# To Staging Dir
define Build/InstallDev

endef


define Build/Compile

endef

#Install your program to  ipkg and Rootfs
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/lib/firmware
	
	$(INSTALL_BIN) files/aq_phy.init $(1)/etc/init.d/aq_phy
	$(CP) files/AQR-G4_v5.6.7-AQR_Marvell_NoSwap_USX_ID44858_VER1922.cld $(1)/lib/firmware
endef

define Build/Clean

endef

$(eval $(call BuildPackage,$(PKG_NAME)))
