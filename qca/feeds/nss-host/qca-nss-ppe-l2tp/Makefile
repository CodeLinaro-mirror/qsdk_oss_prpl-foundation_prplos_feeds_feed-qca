include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-ppe-l2tp
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

define KernelPackage/qca-nss-ppe-l2tp
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel driver for PPE L2TP tunnel (client)
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +kmod-qca-nss-ppe-tun +kmod-ppp +kmod-l2tp +kmod-pppol2tp
  FILES:=$(PKG_BUILD_DIR)/clients/l2tp/qca-nss-ppe-l2tp.ko
  AUTOLOAD:=$(call AutoLoad,53,qca-nss-ppe-l2tp)
endef

define KernelPackage/qca-nss-ppe-l2tp/Description
Kernel module for PPE L2TP-V2 tunnel client
endef

define Build/InstallDev
	$(call Build/InstallDev/qca-nss-ppe-l2tp,$(1))
endef

EXTRA_CFLAGS+= \
	-I$(LINUX_DIR)/net/l2tp/ \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe \

MAKE_OPTS+=l2tp-mgr=y

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-ppe-l2tp))
