include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-netfn-pkt-steer
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r37
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-netfn
PKG_MIRROR_HASH:=64644656becdfd378e5d30b6bbee850bd5ce32680cd331341b963b7c36b67ecf
PKG_VERSION:=ac18e9faeb55545eedde81671e6b3cdb7b807c45

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
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx||TARGET_ipq52xx||TARGET_ipq96xx
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
