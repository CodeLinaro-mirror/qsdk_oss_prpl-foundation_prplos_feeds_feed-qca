include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-ppe-tun
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r26
PKG_RELEASE:=2
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-ppe
PKG_MIRROR_HASH:=skip
PKG_VERSION:=0161cd27ea8d20079814d8562dc59cdb79f1f9d5

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

define KernelPackage/qca-nss-ppe-tun
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel driver for PPE Tunnel (tunnel driver)
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +kmod-qca-nss-ppe +kmod-qca-nss-ppe-vp +kmod-qca-nss-ppe-rule
  FILES:=$(PKG_BUILD_DIR)/drv/ppe_tun/qca-nss-ppe-tun.ko
  AUTOLOAD:=$(call AutoLoad,53,qca-nss-ppe-tun)
endef

define KernelPackage/qca-nss-ppe-tun/Description
Kernel module for PPE Tunnel Driver
endef

ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-ppe-rule),)
EXTRA_CFLAGS+= -DPPE_TUN_RULE_MODULE_ENABLED
endif
EXTRA_CFLAGS+= -Wno-unused-variable

MAKE_OPTS+=ppe-tun=y

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-ppe-tun))
