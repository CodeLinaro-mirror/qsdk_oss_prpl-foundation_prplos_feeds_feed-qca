# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2006-2021 OpenWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=hostapd-qca
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_URL:=http://w1.fi/hostap.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-09-19
PKG_SOURCE_VERSION:=01944c0957
PKG_MIRROR_HASH:=123f541065cf3754e8d6ff01912b8617b6ba74ea5c9e65b3c4ac1cde19779d16

PKG_MAINTAINER:=Felix Fietkau <nbd@openwrt.org>
PKG_LICENSE:=BSD-3-Clause
PKG_CPE_ID:=cpe:/a:w1.fi:hostapd

PKG_BUILD_PARALLEL:=1
PKG_ASLR_PIE_REGULAR:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_kmod-ath9k-qca \
	CONFIG_PACKAGE_kmod-cfg80211-qca \
	CONFIG_PACKAGE_hostapd-qca \
	CONFIG_PACKAGE_hostapd-qca-basic \
	CONFIG_PACKAGE_hostapd-qca-mini \
	CONFIG_WPA_RFKILL_SUPPORT \
	CONFIG_DRIVER_WEXT_SUPPORT \
	CONFIG_DRIVER_11N_SUPPORT \
	CONFIG_DRIVER_11AC_SUPPORT \
	CONFIG_DRIVER_11AX_SUPPORT \
	CONFIG_WPA_ENABLE_WEP

EAPOL_TEST_PROVIDERS:=eapol-test-qca eapol-test-qca-openssl eapol-test-qca-wolfssl

SUPPLICANT_PROVIDERS:=
HOSTAPD_PROVIDERS:=

LOCAL_TYPE=$(strip \
		$(if $(findstring wpad,$(BUILD_VARIANT)),wpad, \
		$(if $(findstring supplicant,$(BUILD_VARIANT)),supplicant, \
		hostapd \
		)))

LOCAL_AND_LIB_VARIANT=$(patsubst hostapd-%,%,\
		      $(patsubst wpad-%,%,\
		      $(patsubst supplicant-%,%,\
		      $(BUILD_VARIANT)\
		      )))

LOCAL_VARIANT=$(patsubst %-internal,%,\
	      $(patsubst %-openssl,%,\
	      $(patsubst %-wolfssl,%,\
	      $(LOCAL_AND_LIB_VARIANT)\
	      )))

SSL_VARIANT=$(strip \
		$(if $(findstring openssl,$(LOCAL_AND_LIB_VARIANT)),openssl,\
		$(if $(findstring wolfssl,$(LOCAL_AND_LIB_VARIANT)),wolfssl,\
		internal\
		)))

CONFIG_VARIANT:=$(LOCAL_VARIANT)
ifeq ($(LOCAL_VARIANT),mesh)
  CONFIG_VARIANT:=full
endif

include $(INCLUDE_DIR)/package.mk

STAMP_CONFIGURED:=$(STAMP_CONFIGURED)_$(CONFIG_WPA_MSG_MIN_PRIORITY)


ifneq ($(CONFIG_DRIVER_11N_SUPPORT),)
  HOSTAPD_IEEE80211N:=y
endif

ifneq ($(CONFIG_DRIVER_11AC_SUPPORT),)
  HOSTAPD_IEEE80211AC:=y
endif

ifneq ($(CONFIG_DRIVER_11AX_SUPPORT),)
  HOSTAPD_IEEE80211AX:=y
endif

DRIVER_MAKEOPTS= \
	CONFIG_ACS=$(CONFIG_PACKAGE_kmod-cfg80211-qca) \
	CONFIG_DRIVER_NL80211=$(CONFIG_PACKAGE_kmod-cfg80211-qca) \
	CONFIG_IEEE80211N=$(HOSTAPD_IEEE80211N) \
	CONFIG_IEEE80211AC=$(HOSTAPD_IEEE80211AC) \
	CONFIG_IEEE80211AX=$(HOSTAPD_IEEE80211AX) \
	CONFIG_DRIVER_WEXT=$(CONFIG_DRIVER_WEXT_SUPPORT) \

ifeq ($(SSL_VARIANT),openssl)
  DRIVER_MAKEOPTS += CONFIG_TLS=openssl CONFIG_SAE=y
  TARGET_LDFLAGS += -lcrypto -lssl

  ifeq ($(LOCAL_VARIANT),basic)
    DRIVER_MAKEOPTS += CONFIG_OWE=y
  endif
  ifeq ($(LOCAL_VARIANT),mesh)
    DRIVER_MAKEOPTS += CONFIG_AP=y CONFIG_MESH=y
  endif
  ifeq ($(LOCAL_VARIANT),full)
    DRIVER_MAKEOPTS += CONFIG_OWE=y CONFIG_SUITEB192=y CONFIG_AP=y CONFIG_MESH=y
  endif
endif

ifeq ($(SSL_VARIANT),wolfssl)
  DRIVER_MAKEOPTS += CONFIG_TLS=wolfssl CONFIG_SAE=y
  TARGET_LDFLAGS += -lwolfssl

  ifeq ($(LOCAL_VARIANT),basic)
    DRIVER_MAKEOPTS += CONFIG_OWE=y
  endif
  ifeq ($(LOCAL_VARIANT),mesh)
    DRIVER_MAKEOPTS += CONFIG_AP=y CONFIG_MESH=y CONFIG_WPS_NFC=1
  endif
  ifeq ($(LOCAL_VARIANT),full)
    DRIVER_MAKEOPTS += CONFIG_OWE=y CONFIG_SUITEB192=y CONFIG_AP=y CONFIG_MESH=y CONFIG_WPS_NFC=1
  endif
endif

ifneq ($(LOCAL_TYPE),hostapd)
  ifdef CONFIG_WPA_RFKILL_SUPPORT
    DRIVER_MAKEOPTS += NEED_RFKILL=y
  endif
endif

ifdef CONFIG_USE_GLIBC
  TARGET_LDFLAGS += -lrt
  TARGET_LDFLAGS_C += -lrt
endif

DRV_DEPENDS:=+PACKAGE_kmod-cfg80211-qca:libnl-tiny


define Package/hostapd-qca/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  TITLE:=IEEE 802.1x Authenticator
  URL:=http://hostap.epitest.fi/
  DEPENDS:=$(DRV_DEPENDS) +hostapd-common-qca +libubus
  USERID:=network=101:network=101
  PROVIDES:=hostapd-qca
  CONFLICTS:=$(HOSTAPD_PROVIDERS)
  HOSTAPD_PROVIDERS+=$(1)
endef

define Package/hostapd-qca
$(call Package/hostapd-qca/Default,$(1))
  TITLE+= (built-in full)
  VARIANT:=full-internal
endef

define Package/hostapd-qca/description
 This package contains a full featured IEEE 802.1x/WPA/EAP/RADIUS
 Authenticator.
endef

define Package/hostapd-qca-openssl
$(call Package/hostapd-qca/Default,$(1))
  TITLE+= (OpenSSL full)
  VARIANT:=full-openssl
  DEPENDS+=+libopenssl
endef

Package/hostapd-qca-openssl/description = $(Package/hostapd-qca/description)

define Package/hostapd-qca-wolfssl
$(call Package/hostapd-qca/Default,$(1))
  TITLE+= (wolfSSL full)
  VARIANT:=full-wolfssl
  DEPENDS+=+libwolfssl
endef

Package/hostapd-qca-wolfssl/description = $(Package/hostapd-qca/description)

define Package/hostapd-qca-basic
$(call Package/hostapd-qca/Default,$(1))
  TITLE+= (WPA-PSK, 11r, 11w)
  VARIANT:=basic
endef

define Package/hostapd-qca-basic/description
 This package contains a basic IEEE 802.1x/WPA Authenticator with WPA-PSK, 802.11r and 802.11w support.
endef

define Package/hostapd-qca-basic-openssl
$(call Package/hostapd-qca/Default,$(1))
  TITLE+= (WPA-PSK, 11r and 11w)
  VARIANT:=basic-openssl
  DEPENDS+=+libopenssl
endef

define Package/hostapd-qca-basic-openssl/description
 This package contains a basic IEEE 802.1x/WPA Authenticator with WPA-PSK, 802.11r and 802.11w support.
endef

define Package/hostapd-qca-basic-wolfssl
$(call Package/hostapd-qca/Default,$(1))
  TITLE+= (WPA-PSK, 11r and 11w)
  VARIANT:=basic-wolfssl
  DEPENDS+=+libwolfssl
endef

define Package/hostapd-qca-basic-wolfssl/description
 This package contains a basic IEEE 802.1x/WPA Authenticator with WPA-PSK, 802.11r and 802.11w support.
endef

define Package/hostapd-qca-mini
$(call Package/hostapd-qca/Default,$(1))
  TITLE+= (WPA-PSK only)
  VARIANT:=mini
endef

define Package/hostapd-qca-mini/description
 This package contains a minimal IEEE 802.1x/WPA Authenticator (WPA-PSK only).
endef


define Package/wpad-qca/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  TITLE:=IEEE 802.1x Auth/Supplicant
  DEPENDS:=$(DRV_DEPENDS) +hostapd-common-qca +libubus
  USERID:=network=101:network=101
  URL:=http://hostap.epitest.fi/
  PROVIDES:=hostapd-qca wpa-supplicant-qca
  CONFLICTS:=$(HOSTAPD_PROVIDERS) $(SUPPLICANT_PROVIDERS)
  HOSTAPD_PROVIDERS+=$(1)
  SUPPLICANT_PROVIDERS+=$(1)
endef

define Package/wpad-qca
$(call Package/wpad-qca/Default,$(1))
  TITLE+= (built-in full)
  VARIANT:=wpad-full-internal
endef

define Package/wpad-qca/description
 This package contains a full featured IEEE 802.1x/WPA/EAP/RADIUS
 Authenticator and Supplicant
endef

define Package/wpad-qca-openssl
$(call Package/wpad-qca/Default,$(1))
  TITLE+= (OpenSSL full)
  VARIANT:=wpad-full-openssl
  DEPENDS+=+libopenssl
endef

Package/wpad-qca-openssl/description = $(Package/wpad-qca/description)

define Package/wpad-qca-wolfssl
$(call Package/wpad-qca/Default,$(1))
  TITLE+= (wolfSSL full)
  VARIANT:=wpad-full-wolfssl
  DEPENDS+=+libwolfssl
endef

Package/wpad-qca-wolfssl/description = $(Package/wpad-qca/description)

define Package/wpad-qca-basic
$(call Package/wpad-qca/Default,$(1))
  TITLE+= (WPA-PSK, 11r, 11w)
  VARIANT:=wpad-basic
endef

define Package/wpad-qca-basic/description
 This package contains a basic IEEE 802.1x/WPA Authenticator and Supplicant with WPA-PSK, 802.11r and 802.11w support.
endef

define Package/wpad-qca-basic-openssl
$(call Package/wpad-qca/Default,$(1))
  TITLE+= (OpenSSL, 11r, 11w)
  VARIANT:=wpad-basic-openssl
  DEPENDS+=+libopenssl
endef

define Package/wpad-qca-basic-openssl/description
 This package contains a basic IEEE 802.1x/WPA Authenticator and Supplicant with WPA-PSK, SAE (WPA3-Personal), 802.11r and 802.11w support.
endef

define Package/wpad-qca-basic-wolfssl
$(call Package/wpad-qca/Default,$(1))
  TITLE+= (wolfSSL, 11r, 11w)
  VARIANT:=wpad-basic-wolfssl
  DEPENDS+=+libwolfssl
endef

define Package/wpad-qca-basic-wolfssl/description
 This package contains a basic IEEE 802.1x/WPA Authenticator and Supplicant with WPA-PSK, SAE (WPA3-Personal), 802.11r and 802.11w support.
endef

define Package/wpad-qca-mini
$(call Package/wpad-qca/Default,$(1))
  TITLE+= (WPA-PSK only)
  VARIANT:=wpad-mini
endef

define Package/wpad-qca-mini/description
 This package contains a minimal IEEE 802.1x/WPA Authenticator and Supplicant (WPA-PSK only).
endef

define Package/wpad-qca-mesh
$(call Package/wpad-qca/Default,$(1))
  DEPENDS+=@PACKAGE_kmod-cfg80211-qca @(!TARGET_uml||BROKEN)
  PROVIDES+=wpa-supplicant-qca-mesh wpad-qca-mesh
endef

define Package/wpad-qca-mesh/description
 This package contains a minimal IEEE 802.1x/WPA Authenticator and Supplicant (with 802.11s mesh and SAE support).
endef

define Package/wpad-qca-mesh-openssl
$(call Package/wpad-qca-mesh,$(1))
  TITLE+= (OpenSSL, 11s, SAE)
  DEPENDS+=+libopenssl
  VARIANT:=wpad-qca-mesh-openssl
endef

Package/wpad-qca-mesh-openssl/description = $(Package/wpad-qca-mesh/description)

define Package/wpad-qca-mesh-wolfssl
$(call Package/wpad-qca-mesh,$(1))
  TITLE+= (wolfSSL, 11s, SAE)
  DEPENDS+=+libwolfssl
  VARIANT:=wpad-qca-mesh-wolfssl
endef

Package/wpad-qca-mesh-wolfssl/description = $(Package/wpad-qca-mesh/description)


define Package/wpa-supplicant-qca/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  TITLE:=WPA Supplicant
  URL:=http://hostap.epitest.fi/wpa_supplicant/
  DEPENDS:=$(DRV_DEPENDS) +hostapd-common-qca +libubus
  USERID:=network=101:network=101
  PROVIDES:=wpa-supplicant-qca
  CONFLICTS:=$(SUPPLICANT_PROVIDERS)
  SUPPLICANT_PROVIDERS+=$(1)
endef

define Package/wpa-supplicant-qca
$(call Package/wpa-supplicant-qca/Default,$(1))
  TITLE+= (built-in full)
  VARIANT:=supplicant-full-internal
endef

define Package/wpa-supplicant-qca-openssl
$(call Package/wpa-supplicant-qca/Default,$(1))
  TITLE+= (OpenSSL full)
  VARIANT:=supplicant-full-openssl
  DEPENDS+=+libopenssl
endef

define Package/wpa-supplicant-qca-wolfssl
$(call Package/wpa-supplicant-qca/Default,$(1))
  TITLE+= (wolfSSL full)
  VARIANT:=supplicant-full-wolfssl
  DEPENDS+=+libwolfssl
endef

define Package/wpa-supplicant-qca/config
	source "$(SOURCE)/Config.in"
endef

define Package/wpa-supplicant-qca-p2p
$(call Package/wpa-supplicant-qca/Default,$(1))
  TITLE+= (Wi-Fi P2P support)
  DEPENDS+=@PACKAGE_kmod-cfg80211-qca
  VARIANT:=supplicant-p2p-internal
endef

define Package/wpa-supplicant-qca-mesh/Default
$(call Package/wpa-supplicant-qca/Default,$(1))
  DEPENDS+=@PACKAGE_kmod-cfg80211-qca @(!TARGET_uml||BROKEN)
  PROVIDES+=wpa-supplicant-qca-mesh
endef

define Package/wpa-supplicant-qca-mesh-openssl
$(call Package/wpa-supplicant-qca-mesh/Default,$(1))
  TITLE+= (OpenSSL, 11s, SAE)
  VARIANT:=supplicant-mesh-openssl
  DEPENDS+=+libopenssl
endef

define Package/wpa-supplicant-qca-mesh-wolfssl
$(call Package/wpa-supplicant-qca-mesh/Default,$(1))
  TITLE+= (wolfSSL, 11s, SAE)
  VARIANT:=supplicant-mesh-wolfssl
  DEPENDS+=+libwolfssl
endef

define Package/wpa-supplicant-qca-basic
$(call Package/wpa-supplicant-qca/Default,$(1))
  TITLE+= (11r, 11w)
  VARIANT:=supplicant-basic
endef

define Package/wpa-supplicant-qca-mini
$(call Package/wpa-supplicant-qca/Default,$(1))
  TITLE+= (minimal)
  VARIANT:=supplicant-mini
endef


define Package/hostapd-common-qca
  TITLE:=hostapd/wpa_supplicant common support files
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
endef

define Package/hostapd-utils-qca
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  TITLE:=IEEE 802.1x Authenticator (utils)
  URL:=http://hostap.epitest.fi/
  DEPENDS:=@$(subst $(space),||,$(foreach pkg,$(HOSTAPD_PROVIDERS),PACKAGE_$(pkg)))
endef

define Package/hostapd-utils-qca/description
 This package contains a command line utility to control the
 IEEE 802.1x/WPA/EAP/RADIUS Authenticator.
endef

define Package/wpa-cli-qca
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  DEPENDS:=@$(subst $(space),||,$(foreach pkg,$(SUPPLICANT_PROVIDERS),PACKAGE_$(pkg)))
  TITLE:=WPA Supplicant command line control utility
endef

define Package/eapol-test-qca/Default
  TITLE:=802.1x auth test utility
  SECTION:=net
  SUBMENU:=WirelessAPD
  CATEGORY:=Network
  DEPENDS:=$(DRV_DEPENDS) +libubus
endef

define Package/eapol-test-qca
  $(call Package/eapol-test-qca/Default,$(1))
  TITLE+= (built-in full)
  VARIANT:=supplicant-full-internal
endef

define Package/eapol-test-qca-openssl
  $(call Package/eapol-test-qca/Default,$(1))
  TITLE+= (OpenSSL full)
  VARIANT:=supplicant-full-openssl
  CONFLICTS:=$(filter-out eapol-test-qca-openssl ,$(EAPOL_TEST_PROVIDERS))
  DEPENDS+=+libopenssl
  PROVIDES:=eapol-test-qca
endef

define Package/eapol-test-qca-wolfssl
  $(call Package/eapol-test-qca/Default,$(1))
  TITLE+= (wolfSSL full)
  VARIANT:=supplicant-full-wolfssl
  CONFLICTS:=$(filter-out eapol-test-qca-openssl ,$(filter-out eapol-test-qca-wolfssl ,$(EAPOL_TEST_PROVIDERS)))
  DEPENDS+=+libwolfssl
  PROVIDES:=eapol-test-qca
endef


ifneq ($(wildcard $(PKG_BUILD_DIR)/.config_*),$(subst .configured_,.config_,$(STAMP_CONFIGURED)))
  define Build/Configure/rebuild
	$(FIND) $(PKG_BUILD_DIR) -name \*.o -or -name \*.a | $(XARGS) rm -f
	rm -f $(PKG_BUILD_DIR)/hostapd/hostapd
	rm -f $(PKG_BUILD_DIR)/wpa_supplicant/wpa_supplicant
	rm -f $(PKG_BUILD_DIR)/.config_*
	touch $(subst .configured_,.config_,$(STAMP_CONFIGURED))
  endef
endif

define Build/Configure
	$(Build/Configure/rebuild)
	$(if $(wildcard ./files/hostapd-$(CONFIG_VARIANT).config), \
		$(CP) ./files/hostapd-$(CONFIG_VARIANT).config $(PKG_BUILD_DIR)/hostapd/.config \
	)
	$(if $(wildcard ./files/wpa_supplicant-$(CONFIG_VARIANT).config), \
		$(CP) ./files/wpa_supplicant-$(CONFIG_VARIANT).config $(PKG_BUILD_DIR)/wpa_supplicant/.config
	)
endef

TARGET_CPPFLAGS := \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-I$(PKG_BUILD_DIR)/src/crypto \
	$(TARGET_CPPFLAGS) \
	-DCONFIG_LIBNL20 \
	-D_GNU_SOURCE \
	$(if $(CONFIG_WPA_MSG_MIN_PRIORITY),-DCONFIG_MSG_MIN_PRIORITY=$(CONFIG_WPA_MSG_MIN_PRIORITY))

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections -flto=jobserver -fuse-linker-plugin -lubox -lubus

ifdef CONFIG_PACKAGE_kmod-cfg80211-qca
  TARGET_LDFLAGS += -lm -lnl-tiny
endif

ifdef CONFIG_WPA_ENABLE_WEP
    DRIVER_MAKEOPTS += CONFIG_WEP=y
endif

define Build/RunMake
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/$(1) \
		$(TARGET_CONFIGURE_OPTS) \
		$(DRIVER_MAKEOPTS) \
		LIBS="$(TARGET_LDFLAGS)" \
		LIBS_c="$(TARGET_LDFLAGS_C)" \
		AR="$(TARGET_CROSS)gcc-ar" \
		BCHECK= \
		$(if $(findstring s,$(OPENWRT_VERBOSE)),V=1) \
		$(2)
endef

define Build/Compile/wpad
	echo ` \
		$(call Build/RunMake,hostapd,-s MULTICALL=1 dump_cflags); \
		$(call Build/RunMake,wpa_supplicant,-s MULTICALL=1 dump_cflags) | \
		sed -e 's,-n ,,g' -e 's^$(TARGET_CFLAGS)^^' \
	` > $(PKG_BUILD_DIR)/.cflags
	sed -i 's/"/\\"/g' $(PKG_BUILD_DIR)/.cflags
	+$(call Build/RunMake,hostapd, \
		CFLAGS="$$$$(cat $(PKG_BUILD_DIR)/.cflags)" \
		MULTICALL=1 \
		hostapd_cli hostapd_multi.a \
	)
	+$(call Build/RunMake,wpa_supplicant, \
		CFLAGS="$$$$(cat $(PKG_BUILD_DIR)/.cflags)" \
		MULTICALL=1 \
		wpa_cli wpa_supplicant_multi.a \
	)
	+export MAKEFLAGS="$(MAKE_JOBSERVER)"; $(TARGET_CC) -o $(PKG_BUILD_DIR)/wpad \
		$(TARGET_CFLAGS) \
		./files/multicall.c \
		$(PKG_BUILD_DIR)/hostapd/hostapd_multi.a \
		$(PKG_BUILD_DIR)/wpa_supplicant/wpa_supplicant_multi.a \
		$(TARGET_LDFLAGS)
endef

define Build/Compile/hostapd
	+$(call Build/RunMake,hostapd, \
		hostapd hostapd_cli \
	)
endef

define Build/Compile/supplicant
	+$(call Build/RunMake,wpa_supplicant, \
		wpa_cli wpa_supplicant \
	)
endef

define Build/Compile/supplicant-full-internal
	+$(call Build/RunMake,wpa_supplicant, \
		eapol_test \
	)
endef

define Build/Compile/supplicant-full-openssl
	+$(call Build/RunMake,wpa_supplicant, \
		eapol_test \
	)
endef

define Build/Compile/supplicant-full-wolfssl
	+$(call Build/RunMake,wpa_supplicant, \
		eapol_test \
	)
endef

define Build/Compile
	$(Build/Compile/$(LOCAL_TYPE))
	$(Build/Compile/$(BUILD_VARIANT))
endef

define Install/hostapd
	$(INSTALL_DIR) $(1)/usr/sbin
endef

define Install/supplicant
	$(INSTALL_DIR) $(1)/usr/sbin
endef

define Package/hostapd-common-qca/install
	$(INSTALL_DIR) $(1)/etc/capabilities $(1)/etc/rc.button $(1)/etc/hotplug.d/ieee80211 $(1)/etc/init.d $(1)/lib/netifd  $(1)/usr/share/acl.d
	$(INSTALL_DATA) ./files/hostapd.sh $(1)/lib/netifd/hostapd.sh
	$(INSTALL_BIN) ./files/wpad.init $(1)/etc/init.d/wpad
	$(INSTALL_BIN) ./files/wps-hotplug.sh $(1)/etc/rc.button/wps
	$(INSTALL_DATA) ./files/wpad_acl.json $(1)/usr/share/acl.d
	$(INSTALL_DATA) ./files/wpad.json $(1)/etc/capabilities
endef

define Package/hostapd-qca/install
	$(call Install/hostapd,$(1))
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hostapd/hostapd $(1)/usr/sbin/
endef
Package/hostapd-qca-basic/install = $(Package/hostapd-qca/install)
Package/hostapd-qca-basic-openssl/install = $(Package/hostapd-qca/install)
Package/hostapd-qca-basic-wolfssl/install = $(Package/hostapd-qca/install)
Package/hostapd-qca-mini/install = $(Package/hostapd-qca/install)
Package/hostapd-qca-openssl/install = $(Package/hostapd-qca/install)
Package/hostapd-qca-wolfssl/install = $(Package/hostapd-qca/install)

ifneq ($(LOCAL_TYPE),supplicant)
  define Package/hostapd-utils-qca/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hostapd/hostapd_cli $(1)/usr/sbin/
  endef
endif

define Package/wpad-qca/install
	$(call Install/hostapd,$(1))
	$(call Install/supplicant,$(1))
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wpad $(1)/usr/sbin/
	$(LN) wpad $(1)/usr/sbin/hostapd
	$(LN) wpad $(1)/usr/sbin/wpa_supplicant
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hostapd/hostapd_cli $(1)/usr/sbin/
endef
Package/wpad-qca-basic/install = $(Package/wpad-qca/install)
Package/wpad-qca-basic-openssl/install = $(Package/wpad-qca/install)
Package/wpad-qca-basic-wolfssl/install = $(Package/wpad-qca/install)
Package/wpad-qca-mini/install = $(Package/wpad-qca/install)
Package/wpad-qca-openssl/install = $(Package/wpad-qca/install)
Package/wpad-qca-wolfssl/install = $(Package/wpad-qca/install)
Package/wpad-qca-mesh-openssl/install = $(Package/wpad-qca/install)
Package/wpad-qca-mesh-wolfssl/install = $(Package/wpad-qca/install)

define Package/wpa-supplicant-qca/install
	$(call Install/supplicant,$(1))
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wpa_supplicant/wpa_supplicant $(1)/usr/sbin/
endef
Package/wpa-supplicant-qca-basic/install = $(Package/wpa-supplicant-qca/install)
Package/wpa-supplicant-qca-mini/install = $(Package/wpa-supplicant-qca/install)
Package/wpa-supplicant-qca-p2p/install = $(Package/wpa-supplicant-qca/install)
Package/wpa-supplicant-qca-openssl/install = $(Package/wpa-supplicant-qca/install)
Package/wpa-supplicant-qca-wolfssl/install = $(Package/wpa-supplicant-qca/install)
Package/wpa-supplicant-qca-mesh-openssl/install = $(Package/wpa-supplicant-qca/install)
Package/wpa-supplicant-qca-mesh-wolfssl/install = $(Package/wpa-supplicant-qca/install)

ifneq ($(LOCAL_TYPE),hostapd)
  define Package/wpa-cli-qca/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/wpa_supplicant/wpa_cli $(1)/usr/sbin/
  endef
endif

ifeq ($(BUILD_VARIANT),supplicant-full-internal)
  define Package/eapol-test-qca/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/wpa_supplicant/eapol_test $(1)/usr/sbin/
  endef
endif

ifeq ($(BUILD_VARIANT),supplicant-full-openssl)
  define Package/eapol-test-qca-openssl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/wpa_supplicant/eapol_test $(1)/usr/sbin/
  endef
endif

ifeq ($(BUILD_VARIANT),supplicant-full-wolfssl)
  define Package/eapol-test-qca-wolfssl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/wpa_supplicant/eapol_test $(1)/usr/sbin/
  endef
endif

$(eval $(call BuildPackage,hostapd-qca))
$(eval $(call BuildPackage,hostapd-qca-basic))
$(eval $(call BuildPackage,hostapd-qca-basic-openssl))
$(eval $(call BuildPackage,hostapd-qca-basic-wolfssl))
$(eval $(call BuildPackage,hostapd-qca-mini))
$(eval $(call BuildPackage,hostapd-qca-openssl))
$(eval $(call BuildPackage,hostapd-qca-wolfssl))
$(eval $(call BuildPackage,wpad-qca))
$(eval $(call BuildPackage,wpad-qca-mesh-openssl))
$(eval $(call BuildPackage,wpad-qca-mesh-wolfssl))
$(eval $(call BuildPackage,wpad-qca-basic))
$(eval $(call BuildPackage,wpad-qca-basic-openssl))
$(eval $(call BuildPackage,wpad-qca-basic-wolfssl))
$(eval $(call BuildPackage,wpad-qca-mini))
$(eval $(call BuildPackage,wpad-qca-openssl))
$(eval $(call BuildPackage,wpad-qca-wolfssl))
$(eval $(call BuildPackage,wpa-supplicant-qca))
$(eval $(call BuildPackage,wpa-supplicant-qca-mesh-openssl))
$(eval $(call BuildPackage,wpa-supplicant-qca-mesh-wolfssl))
$(eval $(call BuildPackage,wpa-supplicant-qca-basic))
$(eval $(call BuildPackage,wpa-supplicant-qca-mini))
$(eval $(call BuildPackage,wpa-supplicant-qca-p2p))
$(eval $(call BuildPackage,wpa-supplicant-qca-openssl))
$(eval $(call BuildPackage,wpa-supplicant-qca-wolfssl))
$(eval $(call BuildPackage,wpa-cli-qca))
$(eval $(call BuildPackage,hostapd-utils-qca))
$(eval $(call BuildPackage,hostapd-common-qca))
$(eval $(call BuildPackage,eapol-test-qca))
$(eval $(call BuildPackage,eapol-test-qca-openssl))
$(eval $(call BuildPackage,eapol-test-qca-wolfssl))
