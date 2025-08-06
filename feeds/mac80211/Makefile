#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mac80211
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_BACKPORTS_VERSION:=965f73fc
PKG_BACKPORTS_SOURCE_URL:=git://git.kernel.org/pub/scm/linux/kernel/git/backports/backports.git
PKG_BACKPORTS_BRANCH:=master

PKG_KERNEL_VERSION:=9a0dddfb30f1
PKG_KERNEL_SOURCE_URL:=http://git.codelinaro.org/clo/qsdk/kvalo/ath.git
PKG_KERNEL_BRANCH:=korg-kvalo/master

PKG_VERSION:=20250213
PKG_SOURCE:=backports-$(PKG_VERSION)-$(LINUX_VERSION)-$(PKG_KERNEL_VERSION).tar.bz2
PKG_SUBDIR:=backports-$(PKG_VERSION)-$(LINUX_VERSION)-$(PKG_KERNEL_VERSION)
PKG_RELEASE:=1
PKG_BUILD_ID:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_SUBDIR)-$(BUILD_VARIANT)/$(PKG_SUBDIR)
PKG_BUILD_PARALLEL:=1

MKHASH ?= $(STAGING_DIR_HOST)/bin/mkhash
PKG_BUILD_ID:=$(shell date | $(MKHASH) md5)
PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

EXTERNAL_HOSTAP_FILE_DIR:=$(TOPDIR)/feeds/feed_qca/feeds/hostapd/

PKG_DRIVERS = \
	mac80211-hwsim

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_kmod-mac80211 \
	CONFIG_PACKAGE_CFG80211_TESTMODE \
	CONFIG_PACKAGE_MAC80211_MESSAGE_TRACING \
	CONFIG_PACKAGE_MAC80211_DEBUGFS \
	CONFIG_PACKAGE_MAC80211_MESH \
	CONFIG_PACKAGE_MAC80211_TRACING \
	CONFIG_PACKAGE_IWLWIFI_DEBUG \
	CONFIG_PACKAGE_IWLWIFI_DEBUGFS \
	CONFIG_PACKAGE_RTLWIFI_DEBUG \

include $(INCLUDE_DIR)/package.mk

WMENU:=Wireless Drivers

define KernelPackage/mac80211/Default
  SUBMENU:=$(WMENU)
  URL:=https://wireless.wiki.kernel.org/
  MAINTAINER:=Felix Fietkau <nbd@nbd.name>
endef

# config_pacakge:
# 1 = OpenWrt KernelPackage name
# 2 = Optional list of variants for which the module may be selected:
#     If empty, the module is only selected with the first variant
#     Use $(ALL_VARIANTS) to allow module selection in all variants
config_package=$(if $(and $(CONFIG_PACKAGE_kmod-$(1)),$(call mac80211_variant_check,$(2))),m)
mac80211_variant_check=$(if $(ALL_VARIANTS),$(filter $(BUILD_VARIANT),$(if $(1),$(1),$(firstword $(ALL_VARIANTS)))),y)

config-y:= \
	WLAN \
	NL80211_TESTMODE \
	CFG80211_CERTIFICATION_ONUS \
	MAC80211_RC_MINSTREL \
	MAC80211_RC_MINSTREL_HT \
	MAC80211_RC_MINSTREL_VHT \
	MAC80211_RC_DEFAULT_MINSTREL \
	WLAN_VENDOR_ADMTEK \
	WLAN_VENDOR_ATH \
	WLAN_VENDOR_RSI \

config-$(call config_package,cfg80211,$(ALL_VARIANTS)) += CFG80211
config-$(CONFIG_PACKAGE_CFG80211_TESTMODE) += NL80211_TESTMODE

config-$(call config_package,mac80211,$(ALL_VARIANTS)) += MAC80211
config-$(CONFIG_PACKAGE_MAC80211_MESH) += MAC80211_MESH
config-$(CONFIG_PACKAGE_kmod-mac80211) += MAC80211_DEBUG_MENU MAC80211_STA_DEBUG MAC80211_MLME_DEBUG
include ath.mk

PKG_CONFIG_DEPENDS += \
	$(patsubst %,CONFIG_PACKAGE_kmod-%,$(PKG_DRIVERS))

define KernelPackage/cfg80211
  $(call KernelPackage/mac80211/Default)
  TITLE:=cfg80211 - wireless configuration API
  DEPENDS+= +iw-full +iwinfo +!USE_PRPLMESH_WHM:wifi-scripts +wireless-regdb +USE_RFKILL:kmod-rfkill
  ABI_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  FILES:= \
	$(PKG_BUILD_DIR)/compat/compat.ko \
	$(PKG_BUILD_DIR)/net/wireless/cfg80211.ko
endef

define Package/ath-legacy-wifi-scripts
  SECTION:=QCA
  CATEGORY:=QCA software
  TITLE:= ATH legacy wifi scripts for kernel6.6
  DEPENDS:=@TARGET_ipq807x||TARGET_ipq50xx||TARGET_ipq60xx||TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx
endef

define Package/ath-legacy-wifi-scripts/install
	$(INSTALL_DIR) $(1)/lib/wifi/
	$(INSTALL_DIR) $(1)/lib/netifd/
	$(INSTALL_DIR) $(1)/lib/netifd/wireless/
ifeq ($(CONFIG_USE_PRPLMESH_WHM),y)
	sed -i 's/OpenWrt/prplOS/g' ./files/lib/wifi/mac80211.sh
endif
	$(INSTALL_BIN) ./files/lib/wifi/mac80211.sh $(1)/lib/wifi/mac80211.sh
	$(INSTALL_BIN) ./files/lib/netifd-wlan/wireless/mac80211.sh $(1)/lib/netifd/wireless/
	$(INSTALL_DATA) $(EXTERNAL_HOSTAP_FILE_DIR)/files/hostapd.sh $(1)/lib/netifd/hostapd.sh
endef

define KernelPackage/cfg80211/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/lib/wifi $(1)/etc/hotplug.d/ieee80211
	$(INSTALL_DIR) $(1)/lib/wifi $(1)/etc/hotplug.d/devcoredump
	$(INSTALL_DIR) $(1)/lib/wifi $(1)/lib/netifd/wireless
	$(INSTALL_DIR) $(1)/lib/wifi/sawf
	$(INSTALL_DIR) $(1)/lib/wifi/sawf/telemetry
	$(INSTALL_DATA) ./files/lib/wifi/def_service_classes.json $(1)/lib/wifi/sawf/
	$(INSTALL_DATA) ./files/lib/wifi/service_classes.json $(1)/lib/wifi/sawf/
	$(INSTALL_DATA) ./files/lib/wifi/telemetry/config.json $(1)/lib/wifi/sawf/telemetry/
	$(INSTALL_DATA) ./files/lib/wifi/telemetry/sla.json $(1)/lib/wifi/sawf/telemetry/
	$(INSTALL_DATA) ./files/lib/wifi/telemetry/sla_detect.json $(1)/lib/wifi/sawf/telemetry/
ifeq ($(CONFIG_KERNEL_FTRACE),y)
	$(INSTALL_DATA) ./files/lib/ftrace_enable_events.sh $(1)/lib
endif
ifneq ($(wildcard ./files/lib/wifi/pre_post_wifi_operations.sh),)
	$(INSTALL_DATA) ./files/lib/wifi/pre_post_wifi_operations.sh $(1)/lib/wifi/
endif
	$(INSTALL_BIN) ./files/lib/performance.sh $(1)/lib
	$(INSTALL_BIN) ./files/lib/smp_affinity_settings.sh $(1)/lib
	$(INSTALL_BIN) ./files/lib/boost_performance.sh $(1)/lib
	$(INSTALL_BIN) ./files/lib/ds_enable.sh $(1)/lib
	$(INSTALL_BIN) ./files/lib/apsta_mode.sh $(1)/lib
ifeq ($(CONFIG_KERNEL_ATHMEMDEBUG),y)
	$(INSTALL_BIN) ./files/lib/memleak_check.sh $(1)/lib
endif
	$(INSTALL_BIN) ./files/coredump.sh $(1)/etc/hotplug.d/devcoredump
	$(INSTALL_BIN) ./files/lib/wifi-config.sh $(1)/etc/hotplug.d/ieee80211/01-wifi-detect
	$(INSTALL_BIN) ./files/etc/init.d/ath11k_nss_enable.sh $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/ath11k_uboot_mod_params.sh $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/qca-nss-pbuf $(1)/etc/init.d
	$(INSTALL_DATA) $(EXTERNAL_HOSTAP_FILE_DIR)/files/dpp-hostapd-event-update.sh $(1)/lib/netifd/dpp-hostapd-event-update
	chmod 0755 $(1)/lib/netifd/dpp-hostapd-event-update
	$(INSTALL_DATA) $(EXTERNAL_HOSTAP_FILE_DIR)/files/dpp-supplicant-event-update.sh $(1)/lib/netifd/dpp-supplicant-event-update
	chmod 0755 $(1)/lib/netifd/dpp-supplicant-event-update
	$(INSTALL_BIN) ./files/etc/init.d/ath12k_dyn_dbg_enable.sh $(1)/etc/init.d
endef

define KernelPackage/cfg80211/description
cfg80211 is the Linux wireless LAN (802.11) configuration API.
endef

define KernelPackage/cfg80211/config
  if PACKAGE_kmod-cfg80211

	config PACKAGE_CFG80211_TESTMODE
		bool "Enable testmode command support"
		default n
		help
		  This is typically used for tests and calibration during
		  manufacturing, or vendor specific debugging features

  endif
endef

define KernelPackage/mac80211
  $(call KernelPackage/mac80211/Default)
  TITLE:=Linux 802.11 Wireless Networking Stack
  # +kmod-crypto-cmac is a runtime only dependency of net/mac80211/aes_cmac.c
  DEPENDS+= +kmod-cfg80211 +kmod-crypto-cmac +kmod-crypto-ccm +kmod-crypto-gcm +hostapd-common \
	+kmod-qca-nss-ppe \
	+kmod-qca-nss-ppe-vp \
	+kmod-qca-nss-ppe-ds
  KCONFIG:=\
	CONFIG_AVERAGE=y \
	CONFIG_QCOM_RPROC_DISABLE_MPD_SUPPORT=y \
	CONFIG_PCIE_QCOM_EARLY_CAL_SUPPORT=y

  FILES:= $(PKG_BUILD_DIR)/net/mac80211/mac80211.ko
  ABI_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  MENU:=1
endef

define KernelPackage/mac80211/config
  if PACKAGE_kmod-mac80211

        if PACKAGE_kmod-qca-nss-ppe-vp
	   config PACKAGE_MAC80211_PPE_SUPPORT
		   bool "Enable PPE support for IPQ platform"
		   default y
		   help
		     This option enables support for PPE in QCA boards
        endif

        if PACKAGE_kmod-qca-nss-ppe-ds
	   config PACKAGE_MAC80211_DS_SUPPORT
		   bool "Enable DS support for IPQ platform"
		   default y
		   help
		     This option enables support for ds netdev in QCA boards.
        endif

        if PACKAGE_kmod-qca-nss-sfe
	   config PACKAGE_MAC80211_SFE_SUPPORT
		   bool "Enable sfe support for IPQ platform"
		   default y
		   help
		     This option enables support for qca sfe in QCA boards
        endif

	config PACKAGE_MAC80211_ATHMEMDEBUG
		bool "Enable memory debug support"
		default n
		help
		  This option enables ATH memory debug support.

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

define KernelPackage/mac80211/description
Generic IEEE 802.11 Networking Stack (mac80211)
endef

define KernelPackage/mac80211-hwsim
  $(call KernelPackage/mac80211/Default)
  TITLE:=mac80211 HW simulation device
  DEPENDS+= +kmod-mac80211 +@DRIVER_11AX_SUPPORT +@DRIVER_11AC_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/virtual/mac80211_hwsim.ko
  AUTOLOAD:=$(call AutoProbe,mac80211_hwsim)
endef

define KernelPackage/wlcore
  $(call KernelPackage/mac80211/Default)
  TITLE:=TI common driver part
  DEPENDS+= +kmod-mmc +kmod-mac80211
  FILES:= \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ti/wlcore/wlcore.ko \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko
  AUTOLOAD:=$(call AutoProbe,wlcore wlcore_sdio)
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

config-$(CONFIG_PACKAGE_MAC80211_PPE_SUPPORT) += MAC80211_PPE_SUPPORT
config-$(CONFIG_PACKAGE_MAC80211_DS_SUPPORT) += MAC80211_BONDED_SUPPORT ATH12K_PPE_DS_SUPPORT ATH12K_BONDED_DS_SUPPORT
config-$(CONFIG_PACKAGE_MAC80211_SFE_SUPPORT) += MAC80211_SFE_SUPPORT
config-$(CONFIG_PACKAGE_MAC80211_MESSAGE_TRACING) += MAC80211_MESSAGE_TRACING ATH10K_TRACING ATH11K_TRACING ATH12K_TRACING
config-$(CONFIG_PACKAGE_MAC80211_DEBUG_MENU) += MAC80211_DEBUG_MENU
config-$(CONFIG_PACKAGE_MAC80211_VERBOSE_DEBUG) += MAC80211_VERBOSE_DEBUG
config-$(CONFIG_PACKAGE_MAC80211_PS_DEBUG) += MAC80211_PS_DEBUG
config-$(CONFIG_PACKAGE_MAC80211_ATHMEMDEBUG) += MAC80211_ATHMEMDEBUG

config-$(call config_package,mac80211-hwsim) += MAC80211_HWSIM

config-y += WL_TI WILINK_PLATFORM_DATA

config-$(CONFIG_LEDS_TRIGGERS) += MAC80211_LEDS

C_DEFINES=

ifeq ($(BUILD_VARIANT),smallbuffers)
	C_DEFINES+= -DCONFIG_ATH10K_SMALLBUFFERS
endif

MAKE_OPTS:= \
	$(subst -C $(LINUX_DIR),-C "$(PKG_BUILD_DIR)",$(KERNEL_MAKEOPTS)) \
	EXTRA_CFLAGS="-I$(PKG_BUILD_DIR)/include $(IREMAP_CFLAGS) $(C_DEFINES) -I$(STAGING_DIR)/usr/include/qca-nss-drv -I$(STAGING_DIR)/usr/include/qca-nss-ppe -I$(STAGING_DIR)/usr/include/qca-nss-clients -I$(TOPDIR)/feeds/feed_qca/feeds/mac80211/src/include/telemetry_agent/inc/ -Wall" \
	KLIB_BUILD="$(LINUX_DIR)" \
	MODPROBE=true \
	KLIB=$(TARGET_MODULES_DIR) \
	KERNEL_SUBLEVEL=$(lastword $(subst ., ,$(KERNEL_PATCHVER))) \
	KBUILD_LDFLAGS_MODULE_PREREQ=

define ConfigVars
$(subst $(space),,$(foreach opt,$(config-$(1)),CPTCFG_$(opt)=$(1)
))
endef

define mac80211_config
$(call ConfigVars,m)$(call ConfigVars,y)
endef
$(eval $(call shexport,mac80211_config))

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	$(PKG_UNPACK)
	$(CP) ./src/* $(PKG_BUILD_DIR)
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
		$(PKG_BUILD_DIR)/include/linux/mhi.h \
		$(PKG_BUILD_DIR)/include/net/ieee80211.h \
		$(PKG_BUILD_DIR)/backport-include/linux/bcm47xx_nvram.h

	echo 'compat-wireless-$(PKG_VERSION)-$(PKG_RELEASE)-$(REVISION)' > $(PKG_BUILD_DIR)/compat_version
endef

ifneq ($(CONFIG_PACKAGE_kmod-cfg80211),)
 define Build/Compile/kmod
	rm -rf $(PKG_BUILD_DIR)/modules
	+$(MAKE) $(PKG_JOBS) $(MAKE_OPTS) modules
 endef
endif

EXTERNAL_PATCH_DIR:=$(CURDIR)/patches-qca

define Build/Patch
	$(if $(QUILT),rm -rf $(PKG_BUILD_DIR)/patches; mkdir -p $(PKG_BUILD_DIR)/patches)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/build,build/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/subsys,subsys/)
#	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/ath,ath/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/ath11k,ath11k/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/ath12k,ath12k/)
	$(if $(QUILT),touch $(PKG_BUILD_DIR)/.quilt_used)
endef

define Quilt/Refresh/Package
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/build,build/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/subsys,subsys/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/ath,ath/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/ath11k,ath11k/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/ath12k,ath12k/)
endef

define Build/Compile
	$(SH_FUNC) var2file "$(call shvar,mac80211_config)" $(PKG_BUILD_DIR)/.config
	$(MAKE) $(MAKE_OPTS) allnoconfig
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

define KernelPackage/ath/install
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/include/ath/ath_sawf.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/include/ath/ath_fse.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/include/ath/ath_dp_accel_cfg.h $(STAGING_DIR)/usr/include/
endef

$(eval EXT_KERNEL_DIR:=$(CONFIG_EXTERNAL_KERNEL_TREE))
IS_EXT_KERNEL_TREE_GIT:=$(shell cd $(EXT_KERNEL_DIR) && git rev-parse --is-inside-work-tree)

ifeq ($(IS_EXT_KERNEL_TREE_GIT), true)
  $(eval _LINUX_SRC:=$(CONFIG_EXTERNAL_KERNEL_TREE))
else
  _LINUX_SRC=$(CONFIG_KERNEL_GIT_CLONE_URI)
endif

ifneq ($(call qstrip,$(_LINUX_SRC)),)
# --reference option doesn't work on git trees synced with "repo", so instead
# we're manually using clone & fetch to speed up sync time
  define FastCloneKernel
	git clone file://$(_LINUX_SRC) $(2) || \
	(rm -rf $(2) && \
	git clone file://$(_LINUX_SRC) $(2))
	(cd $(2); git remote add src $(1); git fetch src)
  endef
else
  define FastCloneKernel
	GIT_NAME=$$$$(echo $(1) | sed -e 's:.*//[^/]*.::g'); \
	git clone $(1) $(2) || \
	([ -n "${CONFIG_GIT_MIRROR}" ] && \
	rm -rf $(2) && \
	git clone $(CONFIG_GIT_MIRROR)$$$$GIT_NAME $(2))
  endef
endif

getLocalBackport ?= $(shell wget $(SERVER_PATH)/$(PKG_SOURCE) -P $(TOPDIR)/dl/);
ifeq ($(FORCED_BACKPORTS),false)
$(if $(wildcard $(DL_DIR)/$(PKG_SOURCE)),,$(call getLocalBackport))
endif

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
	$(call FastCloneKernel,$(PKG_KERNEL_SOURCE_URL),$(TMP_DIR)/dl/$(PKG_NAME)-kernel)
	(cd $(TMP_DIR)/dl/$(PKG_NAME)-kernel && git checkout $(PKG_KERNEL_VERSION))

	git clone $(PKG_BACKPORTS_SOURCE_URL) $(TMP_DIR)/dl/$(PKG_NAME)-source || \
	(rm -rf $(TMP_DIR)/dl/$(PKG_NAME)-source && \
	git clone $(PKG_BACKPORTS_SOURCE_URL) $(TMP_DIR)/dl/$(PKG_NAME)-source)
	cp files/copy-list.ath $(TMP_DIR)/dl/$(PKG_NAME)-source
	(cd $(TMP_DIR)/dl/$(PKG_NAME)-source && git checkout $(PKG_BACKPORTS_VERSION) && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0073-netdevice-mtu-range.cocci && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0075-ndo-stats-64.cocci && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0105-remove-const-from-rchan_callbacks.patch) && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0004-disable-wext-kconfig.patch && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0013-fix-makefile-includes/wireless.patch && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0028-select_queue/mac80211.patch && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0097-skb-list/mac80211-status.patch && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0099-netlink-range/mac80211.patch && \
	rm -f $(TMP_DIR)/dl/$(PKG_NAME)-source/patches/0111-wireless-build-unquote.patch

	$(call backports_mlo_support,$(TMP_DIR)/dl/$(PKG_NAME)-source)
	(cd $(TMP_DIR)/dl/$(PKG_NAME)-source && \
	python3 gentree.py --clean --copy-list ./copy-list.ath \
	$(TMP_DIR)/dl/$(PKG_NAME)-kernel $(TMP_DIR)/dl/$(SUBDIR))
ifeq ($(CONFIG_LINUX_4_4),y)
	(cd $(TMP_DIR)/dl; $(call dl_pack,$(TMP_DIR)/dl/$(FILE),$(SUBDIR)))
else
	(cd $(TMP_DIR)/dl ; if [ -z "$(call dl_tar_pack,$(TMP_DIR)/dl/$(FILE),$(SUBDIR))" ]; then $(call dl_pack,$(TMP_DIR)/dl/$(FILE),$(SUBDIR)); else : ; fi; \
	$(call dl_tar_pack,$(TMP_DIR)/dl/$(FILE),$(SUBDIR)) )
endif
	mv $(TMP_DIR)/dl/$(FILE) $(DL_DIR)
	rm -rf $(TMP_DIR)/dl
endef

define Download/backports
  FILE:=$(PKG_SOURCE)
  SUBDIR:=$(PKG_SUBDIR)
endef
$(if $(wildcard $(DL_DIR)/$(PKG_SOURCE)),,$(eval $(call DownloadBackports,backports)))

$(eval $(foreach drv,$(PKG_DRIVERS),$(call KernelPackage,$(drv))))
$(eval $(call KernelPackage,cfg80211))
$(eval $(call KernelPackage,mac80211))
$(eval $(call BuildPackage,ath-legacy-wifi-scripts))
