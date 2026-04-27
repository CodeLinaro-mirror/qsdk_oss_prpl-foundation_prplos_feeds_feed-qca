include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-wifi-nss-plugins
PKG_LICENSE:=ISC
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.wlan_host_opensource.4.0.r37
PKG_RELEASE:=2
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/src/qca-extns/wlan-open-extns
PKG_MIRROR_HASH:=skip
PKG_VERSION:=0e350f8d685fdc46b57288ce507ae9838dc45c86

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/qca-wifi-nss-plugins
 SECTION:=kernel
 CATEGORY:=Kernel modules
 SUBMENU:=Network Devices
 TITLE:=Wifi Plugin module
 DEPENDS:=+kmod-qca-nss-ecm +kmod-qca-nss-ppe \
	  +PACKAGE_kmod-qca-wifi-unified-profile:kmod-qca-wifi \
	  +PACKAGE_kmod-qca-wifi-lowmem-profile:kmod-qca-wifi \
	  +PACKAGE_kmod-ath12k:kmod-ath12k
 FILES:=$(PKG_BUILD_DIR)/ath/plugin/qca-wifi-nss-plugins/qca-wifi-nss-plugins.ko
endef

define KernelPackage/qca-wifi-nss-plugins/Description
Kernel module for wifi plugins.
endef

EXTRA_CFLAGS+= \
			  -I$(STAGING_DIR)/usr/include/qca-wifi \
			  -I$(STAGING_DIR)/usr/include/qca-nss-ecm \
			  -I$(STAGING_DIR)/usr/include/qca-nss-ppe \
			  -I$(STAGING_DIR)/usr/include/mac80211/uapi/linux

ifneq ($(CONFIG_PACKAGE_kmod-ath),)
MAKE_OPTS+=QCA_WIFI_NSS_PLUGINS_OPEN_PROFILE_ENABLE=y
endif

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)/ath/plugin/qca-wifi-nss-plugins/" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
	cp $(PKG_BUILD_DIR)/ath/plugin/qca-wifi-nss-plugins/Module.symvers $(PKG_BUILD_DIR)/Module.symvers.tmp
endef

define Build/InstallDev/qca-wifi-nss-plugins
	$(INSTALL_DIR) $(1)/usr/include/qca-wifi-nss-plugins
endef

define Build/InstallDev
	$(call Build/InstallDev/qca-wifi-nss-plugins,$(1))
endef

$(eval $(call KernelPackage,qca-wifi-nss-plugins))
