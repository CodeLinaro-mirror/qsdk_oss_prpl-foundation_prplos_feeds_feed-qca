include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-wifi-nss-plugins
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r37
PKG_RELEASE:=2
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-wifi-plugins
PKG_MIRROR_HASH:=skip
PKG_VERSION:=e06e7b603bb70e7c8f9ba1e8a67a1aa25a4fbcdc

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)



include $(INCLUDE_DIR)/package.mk

define KernelPackage/qca-wifi-nss-plugins
 SECTION:=kernel
 CATEGORY:=Kernel modules
 SUBMENU:=Network Devices
 TITLE:=Wifi Plugin module
 DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx||TARGET_ipq52xx||TARGET_ipq96xx \
		  +kmod-qca-nss-ecm +kmod-qca-nss-ppe @!LINUX_3_18 \
		  +PACKAGE_kmod-qca-wifi-unified-profile:kmod-qca-wifi \
		  +PACKAGE_kmod-qca-wifi-lowmem-profile:kmod-qca-wifi \
		  +PACKAGE_kmod-ath12k:kmod-ath12k
 FILES:=$(PKG_BUILD_DIR)/qca-wifi-nss-plugins.ko
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
ifneq ($(CONFIG_PACKAGE_kmod-emesh-sp),)
MAKE_OPTS+=QCA_WIFI_NSS_PLUGINS_OPEN_PROFILE_ENABLE=y
endif
else
ifneq ($(CONFIG_PACKAGE_kmod-emesh-sp),)
MAKE_OPTS+=ECM_CLASSIFIER_MSCS_SCS_ENABLE=y
endif
MAKE_OPTS+=ECM_CLASSIFIER_MSCS_ENABLE=y
endif

ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-drv-mscs),)
ifneq ($(CONFIG_PACKAGE_kmod-emesh-sp),)
MAKE_OPTS+=ECM_CLASSIFIER_MSCS_SCS_ENABLE=y
endif
MAKE_OPTS+=ECM_CLASSIFIER_MSCS_ENABLE=y
endif

ifneq ($(CONFIG_PACKAGE_kmod-ath),)
MAKE_OPTS+=QCA_WIFI_NSS_PLUGINS_OPEN_PROFILE_ENABLE=y
endif

ifneq ($(findstring 6.1, $(LINUX_VERSION)),)
MAKE_OPTS+=ECM_CLASSIFIER_WIFI_ENABLE=y
endif

ifneq ($(findstring 6.6, $(LINUX_VERSION)),)
MAKE_OPTS+=ECM_CLASSIFIER_WIFI_ENABLE=y
endif

ifneq ($(CONFIG_PACKAGE_kmod-ath),)
MAKE_OPTS+=ECM_CLASSIFIER_WIFI_ENABLE=y
endif


define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
endef

define Build/InstallDev/qca-wifi-nss-plugins
	$(INSTALL_DIR) $(1)/usr/include/qca-wifi-nss-plugins
endef

define Build/InstallDev
	$(call Build/InstallDev/qca-wifi-nss-plugins,$(1))
endef

$(eval $(call KernelPackage,qca-wifi-nss-plugins))
