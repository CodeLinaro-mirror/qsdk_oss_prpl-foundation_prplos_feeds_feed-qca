include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mac80211-qca

PKG_BACKPORTS_VERSION:=42a95ce7
PKG_BACKPORTS_SOURCE_URL:=git://git.kernel.org/pub/scm/linux/kernel/git/backports/backports.git
PKG_BACKPORTS_BRANCH:=master

PKG_KERNEL_VERSION:=ef7197996efe
PKG_KERNEL_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/kvalo/ath.git
PKG_KERNEL_BRANCH:=ath12k-bringup-extras

PKG_VERSION:=20220822
PKG_SOURCE:=backports-$(PKG_VERSION)-$(LINUX_VERSION)-$(PKG_KERNEL_VERSION).tar.bz2
PKG_SUBDIR:=backports-$(PKG_VERSION)-$(LINUX_VERSION)-$(PKG_KERNEL_VERSION)
PKG_RELEASE:=1
PKG_BUILD_ID:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_SUBDIR)-$(BUILD_VARIANT)/$(PKG_SUBDIR)
PKG_BUILD_PARALLEL:=1

PKG_BUILD_MLO_SUPPORT:=1

PKG_DRIVERS = \
	lib80211 \
	mac80211-hwsim-qca

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_kmod-mac80211-qca \
	CONFIG_PACKAGE_MAC80211_DEBUGFS \
	CONFIG_PACKAGE_MAC80211_MESH \
	CONFIG_PACKAGE_MAC80211_TRACING

include $(INCLUDE_DIR)/package.mk

WMENU:=Wireless Drivers

ifeq ($(IS_EXT_KERNEL_TREE_GIT), true)
  $(eval _LINUX_SRC:=$(CONFIG_EXTERNAL_KERNEL_TREE))
else
  _LINUX_SRC=$(CONFIG_KERNEL_GIT_CLONE_URI)
endif

ifneq ($(call qstrip,$(CONFIG_KERNEL_GIT_BRANCH)),)
  KERNEL_GIT_BRANCH:=-b $(CONFIG_KERNEL_GIT_BRANCH)
else
  KERNEL_GIT_BRANCH:=
endif

ifneq ($(call qstrip,$(CONFIG_KERNEL_GIT_DEPTH)),)
  KERNEL_GIT_DEPTH:=--depth $(CONFIG_KERNEL_GIT_DEPTH)
else
  KERNEL_GIT_DEPTH:=
endif

ifneq ($(call qstrip,$(CONFIG_KERNEL_GIT_REF)),)
  KERNEL_GIT_REF:=git checkout $(CONFIG_KERNEL_GIT_REF);
else
  KERNEL_GIT_REF:=
endif

KERNEL_SOURCE_SUBDIR:=linux-$(LINUX_VERSION)$(KERNEL_NAME_SUFFIX)

define CloneKernel	
	git clone $(_LINUX_SRC) $(KERNEL_GIT_DEPTH) $(KERNEL_GIT_BRANCH) $(2) || \
	(rm -rf $(2) && \
	git clone $(_LINUX_SRC) $(KERNEL_GIT_DEPTH) $(KERNEL_GIT_BRANCH) $(2))
	(cd $(2);$(KERNEL_GIT_REF) git remote add src $(1); git fetch src) 	
endef

ifeq ($(PKG_BUILD_MLO_SUPPORT),1)
  define backports_mlo_support
	$(info Backports mlo support enabled)
	sed -i 's/struct ieee80211_tx_info \*info;/ktime_t ack_hwtstamp;/' \
			$(1)/patches/0097-skb-list/mac80211-status.patch
	sed -i 's/struct sk_buff \*skb;/u8 n_rates;/' \
			$(1)/patches/0097-skb-list/mac80211-status.patch
	sed -i '13s/.*/ /' \
			$(1)/patches/0097-skb-list/mac80211-status.patch
	sed -i '58,75d' $(1)/patches/0099-netlink-range/mac80211.patch
  endef
else
  define backports_mlo_support
	$(info Backports mlo support disabled)
  endef
endif

define DownloadBackports
  $(eval $(Download/Defaults))
  $(eval $(Download/backports))

  $(foreach dep,$(DOWNLOAD_RDEP),
    $(dep): $(DL_DIR)/$(FILE)
  )
  download: $(DL_DIR)/$(FILE)

  $(DL_DIR)/$(FILE):
	mkdir -p $(TMP_DIR)/dl/$(PKG_NAME)-$(PKG_VERSION)
	$(call CloneKernel,$(PKG_KERNEL_SOURCE_URL),$(TMP_DIR)/dl/$(PKG_NAME)-kernel)
	(cd $(TMP_DIR)/dl/$(PKG_NAME)-kernel && git checkout $(PKG_KERNEL_VERSION))

	git clone $(PKG_BACKPORTS_SOURCE_URL) $(TMP_DIR)/dl/$(PKG_NAME)-source || \
	(rm -rf $(TMP_DIR)/dl/$(PKG_NAME)-source && \
	git clone $(PKG_BACKPORTS_SOURCE_URL) $(TMP_DIR)/dl/$(PKG_NAME)-source)
	cp files/copy-list.ath $(TMP_DIR)/dl/$(PKG_NAME)-source
	(cd $(TMP_DIR)/dl/$(PKG_NAME)-source && git checkout $(PKG_BACKPORTS_VERSION) && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0073-netdevice-mtu-range.cocci && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0075-ndo-stats-64.cocci && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0105-remove-const-from-rchan_callbacks.patch)
	$(call backports_mlo_support,$(TMP_DIR)/dl/$(PKG_NAME)-source)
	(cd $(TMP_DIR)/dl/$(PKG_NAME)-source && \
	python2 ./gentree.py --clean --copy-list ./copy-list.ath \
		$(TMP_DIR)/dl/$(PKG_NAME)-kernel $(TMP_DIR)/dl/$(SUBDIR))

	(cd $(TMP_DIR)/dl ; if [ -z "$(call dl_tar_pack,$(TMP_DIR)/dl/$(FILE),$(SUBDIR))" ]; then $(call dl_pack,$(TMP_DIR)/dl/$(FILE),$(SUBDIR)); else : ; fi; \
	$(call dl_tar_pack,$(TMP_DIR)/dl/$(FILE),$(SUBDIR)) )

	mv $(TMP_DIR)/dl/$(FILE) $(DL_DIR)
	rm -rf $(TMP_DIR)/dl
endef

define Download/backports
  FILE:=$(PKG_SOURCE)
  SUBDIR:=$(PKG_SUBDIR)
endef

$(if $(wildcard $(DL_DIR)/$(PKG_SOURCE)),,$(eval $(call DownloadBackports,backports)))

define KernelPackage/mac80211-qca/Default
  SUBMENU:=$(WMENU)
  URL:=https://wireless.wiki.kernel.org/
  MAINTAINER:=Felix Fietkau <nbd@nbd.name>
endef

config_package=$(if $(CONFIG_PACKAGE_kmod-$(1)),m)

config-y:= \
	WLAN \
	NL80211_TESTMODE \
	CFG80211_WEXT \
	CFG80211_INTERNAL_REGDB \
	CFG80211_CERTIFICATION_ONUS \
	MAC80211_RC_MINSTREL \
	MAC80211_RC_MINSTREL_HT \
	MAC80211_RC_MINSTREL_VHT \
	MAC80211_RC_DEFAULT_MINSTREL \
	MAC80211_LEDS \
	WLAN_VENDOR_ADMTEK \
	WLAN_VENDOR_ATH \
	WLAN_VENDOR_ATMEL \
	WLAN_VENDOR_BROADCOM \
	WLAN_VENDOR_CISCO \
	WLAN_VENDOR_INTEL \
	WLAN_VENDOR_INTERSIL \
	WLAN_VENDOR_MARVELL \
	WLAN_VENDOR_MEDIATEK \
	WLAN_VENDOR_RALINK \
	WLAN_VENDOR_REALTEK \
	WLAN_VENDOR_RSI \
	WLAN_VENDOR_ST \
	WLAN_VENDOR_TI \
	WLAN_VENDOR_ZYDAS \

config-$(call config_package,cfg80211-qca) += CFG80211

config-$(call config_package,mac80211-qca) += MAC80211
config-$(CONFIG_PACKAGE_MAC80211_MESH) += MAC80211_MESH

include ath.mk

PKG_CONFIG_DEPENDS += \
	$(patsubst %,CONFIG_PACKAGE_kmod-%,$(PKG_DRIVERS))

define KernelPackage/cfg80211-qca
  $(call KernelPackage/mac80211-qca/Default)
  TITLE:=cfg80211 - wireless configuration API
  DEPENDS+= +iw-qca #+wireless-regdb
  ABI_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  FILES:= \
	$(PKG_BUILD_DIR)/compat/compat.ko \
	$(PKG_BUILD_DIR)/net/wireless/cfg80211.ko
endef

define KernelPackage/cfg80211-qca/description
cfg80211 is the Linux wireless LAN (802.11) configuration API.
endef

define KernelPackage/mac80211-qca
  $(call KernelPackage/mac80211-qca/Default)
  TITLE:=Linux 802.11 Wireless Networking Stack
  # +kmod-crypto-cmac is a runtime only dependency of net/mac80211/aes_cmac.c
  DEPENDS+= +kmod-cfg80211-qca +hostapd-common-qca
  KCONFIG:=\
	CONFIG_AVERAGE=y
  FILES:= $(PKG_BUILD_DIR)/net/mac80211/mac80211.ko
  ABI_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  MENU:=1
endef

define KernelPackage/mac80211-qca/config
  if PACKAGE_kmod-mac80211-qca

	config PACKAGE_MAC80211_DEBUGFS
		bool "Export mac80211 internals in DebugFS"
		select KERNEL_DEBUG_FS
		default y
		help
		  Select this to see extensive information about
		  the internal state of mac80211 in debugfs.

	config PACKAGE_MAC80211_TRACING
		bool "Enable tracing (mac80211 and supported drivers)"
		select KERNEL_FTRACE
		select KERNEL_ENABLE_DEFAULT_TRACERS
		default n
		help
		  Select this to enable tracing of mac80211 and
		  related wifi drivers (using trace-cmd).

	config PACKAGE_MAC80211_MESH
		bool "Enable 802.11s mesh support"
		default y

  endif
endef

define KernelPackage/mac80211-qca/description
Generic IEEE 802.11 Networking Stack (mac80211)
endef

define KernelPackage/lib80211
  $(call KernelPackage/mac80211-qca/Default)
  TITLE:=802.11 Networking stack
  DEPENDS:=+kmod-cfg80211-qca +kmod-crypto-hash +kmod-crypto-ccm
  FILES:= \
	$(PKG_BUILD_DIR)/net/wireless/lib80211.ko \
	$(PKG_BUILD_DIR)/net/wireless/lib80211_crypt_wep.ko \
	$(PKG_BUILD_DIR)/net/wireless/lib80211_crypt_ccmp.ko \
	$(PKG_BUILD_DIR)/net/wireless/lib80211_crypt_tkip.ko
  AUTOLOAD:=$(call AutoProbe, \
	lib80211 \
	lib80211_crypt_wep \
	lib80211_crypt_ccmp \
	lib80211_crypt_tkip \
  )
endef

define KernelPackage/lib80211/description
 Kernel modules for 802.11 Networking stack
 Includes:
 - lib80211
 - lib80211_crypt_wep
 - lib80211_crypt_tkip
 - lib80211_crytp_ccmp
endef


define KernelPackage/mac80211-hwsim-qca
  $(call KernelPackage/mac80211-qca/Default)
  TITLE:=mac80211 HW simulation device
  DEPENDS+= +kmod-mac80211-qca +@DRIVER_11AC_SUPPORT +@DRIVER_11N_SUPPORT +@DRIVER_11W_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/mac80211_hwsim.ko
  AUTOLOAD:=$(call AutoProbe,mac80211_hwsim)
endef

ifdef CONFIG_PACKAGE_MAC80211_DEBUGFS
  config-y += \
	CFG80211_DEBUGFS \
	MAC80211_DEBUGFS
endif

ifdef CONFIG_PACKAGE_MAC80211_TRACING
  config-y += \
	IWLWIFI_DEVICE_TRACING
endif

config-$(call config_package,lib80211) += LIB80211 LIB80211_CRYPT_WEP LIB80211_CRYPT_CCMP LIB80211_CRYPT_TKIP
config-$(call config_package,mac80211-hwsim-qca) += MAC80211_HWSIM
config-$(CONFIG_PACKAGE_kmod-ath12k-qca) += ATH12K_SPECTRAL
MAKE_OPTS:= -C "$(PKG_BUILD_DIR)" \
	CROSS_COMPILE="$(KERNEL_CROSS)" \
        ARCH="$(LINUX_KARCH)" \
	EXTRA_CFLAGS="-I$(PKG_BUILD_DIR)/include $(IREMAP_CFLAGS) -I$(STAGING_DIR)/usr/include/qca-nss-drv -I$(STAGING_DIR)/usr/include/qca-nss-clients -Wno-incompatible-pointer-types -Wno-discarded-qualifiers -Wno-int-conversion -Wno-unused-function -Wno-implicit-fallthrough" \
	KLIB_BUILD="$(LINUX_DIR)" \
	MODPROBE=true \
	KLIB=$(TARGET_MODULES_DIR) \
	KERNEL_SUBLEVEL=$(lastword $(subst ., ,$(KERNEL_PATCHVER))) \
	KBUILD_MODPOST_WARN=1 \
	KBUILD_LDFLAGS_MODULE_PREREQ=

define ConfigVars
$(subst $(space),,$(foreach opt,$(config-$(1)),CPTCFG_$(opt)=$(1)
))
endef

define mac80211-qca_config
$(call ConfigVars,m)$(call ConfigVars,y)
endef
$(eval $(call shexport,mac80211-qca_config))

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	$(PKG_UNPACK)
	$(Build/Patch)
	rm -rf \
		$(PKG_BUILD_DIR)/include/linux/ssb \
		$(PKG_BUILD_DIR)/include/linux/bcma \
		$(PKG_BUILD_DIR)/include/net/bluetooth

	rm -f \
		$(PKG_BUILD_DIR)/include/linux/cordic.h \
		$(PKG_BUILD_DIR)/include/linux/crc8.h \
		$(PKG_BUILD_DIR)/include/linux/eeprom_93cx6.h \
		$(PKG_BUILD_DIR)/include/linux/wl12xx.h \
		$(PKG_BUILD_DIR)/include/linux/spi/libertas_spi.h \
		$(PKG_BUILD_DIR)/include/net/ieee80211.h \
		$(PKG_BUILD_DIR)/backport-include/linux/bcm47xx_nvram.h

	echo 'compat-wireless-$(PKG_VERSION)-$(PKG_RELEASE)-$(REVISION)' > $(PKG_BUILD_DIR)/compat_version
endef

define Build/Patch
	$(if $(QUILT),rm -rf $(PKG_BUILD_DIR)/patches; mkdir -p $(PKG_BUILD_DIR)/patches)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/qca,qca/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/pending,pending/)
	$(if $(QUILT),touch $(PKG_BUILD_DIR)/.quilt_used)
endef

define Quilt/Refresh/Package
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/qca,qca/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/pending,pending/)
endef

ifneq ($(CONFIG_PACKAGE_kmod-cfg80211-qca)$(CONFIG_PACKAGE_kmod-lib80211),)
 define Build/Compile/kmod
	rm -rf $(PKG_BUILD_DIR)/modules
	+$(MAKE) $(PKG_JOBS) $(MAKE_OPTS) modules
 endef
endif

define Build/Compile
	$(SH_FUNC) var2file "$(call shvar,mac80211-qca_config)" $(PKG_BUILD_DIR)/.config
	$(MAKE) $(MAKE_OPTS) olddefconfig
	$(call Build/Compile/kmod)
endef

define Build/InstallDev
	mkdir -p \
		$(1)/usr/include/mac80211 \
		$(1)/usr/include/mac80211-backport \
		$(1)/usr/include/mac80211/ath \
		$(1)/usr/include/net/mac80211
	$(CP) $(PKG_BUILD_DIR)/net/mac80211/*.h $(PKG_BUILD_DIR)/include/* $(1)/usr/include/mac80211/
	$(CP) $(PKG_BUILD_DIR)/backport-include/* $(1)/usr/include/mac80211-backport/
	$(CP) $(PKG_BUILD_DIR)/net/mac80211/rate.h $(1)/usr/include/net/mac80211/
	$(CP) $(PKG_BUILD_DIR)/drivers/net/wireless/ath/*.h $(1)/usr/include/mac80211/ath/
	rm -f $(1)/usr/include/mac80211-backport/linux/module.h
endef


define KernelPackage/cfg80211-qca/install
	$(INSTALL_DIR) $(1)/lib/wifi $(1)/lib/netifd/wireless
	$(INSTALL_DATA) ./files/lib/wifi/mac80211.sh $(1)/lib/wifi
	$(INSTALL_BIN) ./files/lib/netifd/wireless/mac80211.sh $(1)/lib/netifd/wireless
	$(INSTALL_DIR) $(1)/etc/hotplug.d/ieee80211
	$(INSTALL_DATA) ./files/mac80211.hotplug $(1)/etc/hotplug.d/ieee80211/10-wifi-detect
endef

$(eval $(foreach drv,$(PKG_DRIVERS),$(call KernelPackage,$(drv))))
$(eval $(call KernelPackage,cfg80211-qca))
$(eval $(call KernelPackage,mac80211-qca))
