include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-ppe-mirror-test
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r30
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-ppe
PKG_MIRROR_HASH:=d99840a4efe2d5fc09b2783b29ab75461116c40fa6f4866bd25ce1e592b900e3
PKG_VERSION:=d53eff24bf257a8bb1b2f68beb3aa06332bfd567

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

define KernelPackage/qca-nss-ppe-mirror-test
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel driver for PPE test module
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx \
		+kmod-qca-nss-ppe-rule
  FILES:=$(PKG_BUILD_DIR)/test/qca-nss-ppe-mirror-test.ko
endef

define KernelPackage/qca-nss-ppe-mirror-test/Description
   Kernel module for PPE test driver
endef

define Build/InstallDev/qca-nss-ppe-mirror-test
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-ppe
endef

ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-ppe-rule),)
MAKE_OPTS+=ppe-mirror-test=y
endif

define Build/InstallDev
	$(call Build/InstallDev/qca-nss-ppe-mirror-test,$(1))
endef

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-ssdk \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/fal \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/init \

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-ppe-mirror-test))
