include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-ppe-vxlanmgr
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r29
PKG_RELEASE:=2
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-ppe
PKG_MIRROR_HASH:=skip
PKG_VERSION:=8faef225c9f62ac34bb1e097cd8aebaa5f0b89e5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

PKG_BUILD_DEPENDS :=
MAKE_OPTS:=

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_ipq),y)
subtarget:=$(SUBTARGET)
else
subtarget:=$(CONFIG_TARGET_BOARD)
endif

define KernelPackage/qca-nss-ppe-vxlanmgr
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel driver for PPE VxLAN tunnel client
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx||TARGET_ipq96xx||TARGET_ipq52xx \
		+kmod-qca-nss-ppe-tun \
		+kmod-qca-nss-ppe-bridge-mgr \
		+kmod-vxlan
  FILES:=$(PKG_BUILD_DIR)/clients/vxlanmgr/qca-nss-ppe-vxlanmgr.ko
  AUTOLOAD:=$(call AutoLoad,53,qca-nss-ppe-vxlanmgr)
endef

define KernelPackage/qca-nss-ppe-vxlanmgr/Description
Kernel driver for PPE VxLAN tunnel client
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-ppe
	$(CP) $(PKG_BUILD_DIR)/exports/* $(1)/usr/include/qca-nss-ppe
endef

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-ssdk \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/fal \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/init \
	-Wno-unused-variable


ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-ppe-vxlanmgr),)
MAKE_OPTS+=vxlanmgr=y
endif

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-ppe-vxlanmgr))
