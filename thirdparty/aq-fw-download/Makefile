include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=aq-fw-download
PKG_BRANCH:=master
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/aq-fw-download

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=network
  CATEGORY:=Network
  DEPENDS:=@TARGET_ipq806x||TARGET_ipq||TARGET_ipq40xx||TARGET_ipq807x||TARGET_ipq60xx||TARGET_ipq95xx
  TITLE:=Aquantia FW downloader utitlity
endef

define Package/$(PKG_NAME)/description
  Aquantia FW downloader utitlity
endef


# To Staging Dir
define Build/InstallDev

endef


define Build/Compile

endef

#Install your program to  ipkg and Rootfs
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	
	$(INSTALL_BIN) files/aq-fw-download $(1)/usr/sbin/
endef

define Build/Clean

endef

$(eval $(call BuildPackage,$(PKG_NAME)))
