include $(TOPDIR)/rules.mk

PKG_NAME:=nss-tcp-st-cli
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r29
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-speedtest
PKG_MIRROR_HASH:=skip
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

define Package/nss-tcp-st-cli
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=NSS TCP SpeedTest
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +libnl +kmod-qca-nss-netfn-tcpst +libnl-tcpst +libcurl
endef

define Package/nss-tcp-st-cli/description
 Userspace utility for NSS TCP Speedtest compliant with TR-143.
endef

EXTRA_CFLAGS:= $(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include/qca-nss-netfn \
	      -I$(STAGING_DIR)/usr/include/libnl3 \
	      -I$(STAGING_DIR)/usr/include/libnl-tcpst \

EXTRA_LDFLAGS:= $(TARGET_LDFLAGS) -L$(STAGING_DIR)/nss-tcp-st

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/nss-tcp-st-cli \
		CC="$(TARGET_CC)" \
		CFLAGS="$(EXTRA_CFLAGS)" \
		LD_LIBRARY_PATH="$(EXTRA_LDFLAGS)"
endef

define Package/nss-tcp-st-cli/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nss-tcp-st-cli/obj/nss-tcp-st $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,nss-tcp-st-cli))
