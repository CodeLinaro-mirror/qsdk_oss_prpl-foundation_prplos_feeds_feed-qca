include $(TOPDIR)/rules.mk

PKG_NAME:=nss-tcp-st
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r29
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-speedtest
PKG_MIRROR_HASH:=895295d63c3d9755c9563c639c26b6fc832bf34d82a6aa9bc76aa1e601d179f6
PKG_VERSION:=28a5b461fb95f554d2f2ef321610facd0c4a6e90

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(DUMP)$(PKG_VERSION),)
  PKG_VERSION:=$(shell git ls-remote $(PKG_SOURCE_URL) $(PKG_BRANCH) | cut -b -7)
endif

PKG_BUILD_DEPENDS :=
MAKE_OPTS:=

define Package/libnl-tcpst
  SECTION:=Libs
  CATEGORY:=Libraries
  TITLE:=Library to facilitate communication from user to kernel for the TCP ST netlink families
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +libnl +kmod-qca-nss-netfn-tcpst
endef

define Package/libnl-tcpst/description
 Library for TCP Speedtest using TCP ST netlink family.
endef

EXTRA_CFLAGS:= -I$(STAGING_DIR)/usr/include/qca-nss-netfn \
              -I$(STAGING_DIR)/usr/include/libnl3
EXTRA_LDFLAGS:= -L$(STAGING_DIR)/nss-tcp-st

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/nss-tcp-st \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR) " \
		CFLAGS="$(EXTRA_CFLAGS)" \
		LD_LIBRARY_PATH="$(EXTRA_LDFLAGS)"
endef

define Package/libnl-tcpst/install
	$(INSTALL_DIR) $(1)/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/nss-tcp-st/obj/libnl-tcpst.so $(1)/lib
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/libnl-tcpst
	$(CP) $(PKG_BUILD_DIR)/nss-tcp-st/obj/libnl-tcpst.so $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/nss-tcp-st/include/* $(STAGING_DIR)/usr/include/libnl-tcpst
endef

$(eval $(call BuildPackage,libnl-tcpst))
