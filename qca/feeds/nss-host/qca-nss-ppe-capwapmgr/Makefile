include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-ppe-capwapmgr
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r26
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-ppe
PKG_MIRROR_HASH:=skip
PKG_VERSION:=51442d1aa846dc8a495e5ed8e845f92545be05a7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_ipq),y)
subtarget:=$(SUBTARGET)
else
subtarget:=$(CONFIG_TARGET_BOARD)
endif

define KernelPackage/qca-nss-ppe-capwapmgr
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel driver for NSS capwap manager
  DEPENDS:=@TARGET_ipq95xx +kmod-qca-nss-drv-lite \
		+kmod-pppoe @!LINUX_3_18 \
		+kmod-qca-nss-ppe-vp \
		+kmod-qca-nss-ppe-dtlsmgr
  FILES:=$(PKG_BUILD_DIR)/clients/capwapmgr/qca-nss-capwapmgr.ko
endef

define KernelPackage/qca-nss-ppe-capwapmgr/Description
Kernel modules for NSS capwap manager
endef


define Build/InstallDev
	$(call Build/InstallDev/qca-nss-ppe-capwapmgr,$(1))
endef

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-nss-drv \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe \
	-I$(STAGING_DIR)/usr/include/qca-nss-dp \
	-I$(STAGING_DIR)/usr/include/qca-ssdk \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/fal \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/init

MAKE_OPTS+=capwap-mgr=y
EXTRA_CFLAGS += -DNSS_CAPWAPMGR_ONE_NETDEV

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-ppe-capwapmgr))
