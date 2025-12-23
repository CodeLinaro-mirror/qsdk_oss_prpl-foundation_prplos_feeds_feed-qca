include $(TOPDIR)/rules.mk

PKG_NAME:=wifi-helper-scripts
PKG_VERSION:=1.0
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/wifi-helper-scripts
  SECTION:=WLAN-INTERNAL
  CATEGORY:=QTI software
  TITLE:=wifi-helper scripts for WiFi
endef

define Package/wifi-helper-scripts/description
  wifi-helper-scripts holds the scripts required to bring up WiFi
endef

define Build/Compile
endef

define Package/wifi-helper-scripts/install
	mkdir -p $(1)/lib/netifd/
	$(INSTALL_DIR) $(1)/lib/netifd/
	$(INSTALL_BIN) ./files/utils.sh $(1)/lib/netifd/
	$(INSTALL_BIN) ./files/netifd-proto.sh $(1)/lib/netifd/
endef

$(eval $(call BuildPackage,wifi-helper-scripts))
