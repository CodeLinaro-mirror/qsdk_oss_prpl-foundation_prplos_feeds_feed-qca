include $(TOPDIR)/rules.mk

PKG:=nss-udp-st
PKG_NAME:=$(PKG)
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r29
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-speedtest
PKG_MIRROR_HASH:=c436b81e863c4e940603db66f135c128419308e73887fdf06e60d1fb05726c48
PKG_VERSION:=28a5b461fb95f554d2f2ef321610facd0c4a6e90

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=QTI
  CATEGORY:=QTI software
  URL:=http://www.qualcomm.com
  MAINTAINER:=Qualcomm Technologies, Inc.
  TITLE:= NSS UDP SpeedTest
  DEPENDS:= @TARGET_ipq50xx||TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +kmod-nss-udp-st-drv
endef

define Package/$(PKG_NAME)/description/Default
	A userspace utility for host data path nss udp speedtest
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/nss-udp-st-drv/

define Build/Compile
$(MAKE) -C $(PKG_BUILD_DIR)/nss-udp-st \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nss-udp-st/nss-udp-st $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,$(PKG)))
