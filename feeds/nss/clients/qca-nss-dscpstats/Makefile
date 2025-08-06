include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-dscpstats
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r29
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-dscpstats
PKG_MIRROR_HASH:=skip
PKG_VERSION:=35f8409213188c5f2d820740b4b74eddf8c7a379

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_ipq),y)
subtarget:=$(SUBTARGET)
else
subtarget:=$(CONFIG_TARGET_BOARD)
endif

define KernelPackage/qca-nss-dscpstats
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel driver for NSS STAT DSCP
  DEPENDS:=+kmod-qca-nss-ecm
  FILES:=$(PKG_BUILD_DIR)/qca-nss-dscpstats.ko
endef

define KernelPackage/qca-nss-dscpstats/Description
Kernel module for NSS STAT DSCP
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-dscpstats
	$(CP) $(PKG_BUILD_DIR)/exports/* $(1)/usr/include/qca-nss-dscpstats/
endef

define KernelPackage/qca-nss-dscpstats/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/qca-nss-dscpstats.init $(1)/etc/init.d/qca-nss-dscpstats
endef

EXTRA_CFLAGS += -I$(PKG_BUILD_DIR)/exports \
	      -I$(STAGING_DIR)/usr/include/qca-nss-ecm \
	      -I$(STAGING_DIR)/usr/include/libnl3

MAKE_OPTS+=qca-nss-dscpstats=m

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-dscpstats))
