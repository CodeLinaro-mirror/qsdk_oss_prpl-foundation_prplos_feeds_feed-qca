include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-ppe-qdisc
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r30
PKG_RELEASE:=2
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-ppe
PKG_MIRROR_HASH:=6b4323e866ff0293eaf6add8316ffc5ffcfadbbf7fc6cddfb80755d609721796
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

define KernelPackage/qca-nss-ppe-qdisc
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel module for configuring schedulers and shapers in PPE
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +kmod-qca-nss-ppe
  FILES:=$(PKG_BUILD_DIR)/drv/ppe_qdisc/qca-nss-ppe-qdisc.ko
  AUTOLOAD:=$(call AutoLoad,52,qca-nss-ppe-qdisc)
endef

define KernelPackage/qca-nss-ppe-qdisc/Description
   Kernel module for configuring schedulers and shapers in PPE
endef

define Build/InstallDev/qca-nss-ppe-qdisc
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-ppe
endef

define Build/InstallDev
	$(call Build/InstallDev/qca-nss-ppe-qdisc,$(1))
endef

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-ssdk \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/fal \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/init \

MAKE_OPTS+=ppe-qdisc=y

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-ppe-qdisc))
