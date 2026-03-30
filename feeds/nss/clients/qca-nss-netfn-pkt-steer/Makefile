include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-netfn-pkt-steer
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r30
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-netfn
PKG_MIRROR_HASH:=f5a50382b2777a95b87ead3d497730f9b3f8364a5425c62ff1c6f9d7d3b815ae
PKG_VERSION:=5cf1b6cf1d10754f680d6fb96fc1eacea7178c5d

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

define KernelPackage/qca-nss-netfn-pkt-steer
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx
  TITLE:=NSS network function for pkt steer
  FILES:=$(PKG_BUILD_DIR)/offload/pkt_steer/qca-nss-netfn-pkt-steer.ko
  AUTOLOAD:=$(call AutoLoad,53,qca-nss-netfn-pkt-steer)
endef

ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-netfn-pkt-steer),)
MAKE_OPTS+=pkt_steer=y
endif

define KernelPackage/qca-nss-netfn-pkt-steer/Description
NSS network function for pkt steer.
endef

define Build/InstallDev/qca-nss-netfn-pkt-steer
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-netfn
	$(CP) $(PKG_BUILD_DIR)/exports/* $(1)/usr/include/qca-nss-netfn/
	$(CP) $(PKG_BUILD_DIR)/offload/exports/netfn_pkt_steer.h $(1)/usr/include/qca-nss-netfn/
endef

define KernelPackage/qca-nss-netfn-pkt-steer/install
	$(INSTALL_DIR) $(1)/usr/bin
endef

define Build/InstallDev
	$(call Build/InstallDev/qca-nss-netfn-pkt-steer,$(1))
endef

EXTRA_CFLAGS+= \
	-I$(PKG_BUILD_DIR)/offload/exports \

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-netfn-pkt-steer))
