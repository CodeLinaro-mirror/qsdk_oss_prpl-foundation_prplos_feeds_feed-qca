include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-ppe-netlink
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r30
PKG_RELEASE:=2
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-ppe
PKG_MIRROR_HASH:=skip
PKG_VERSION:=d53eff24bf257a8bb1b2f68beb3aa06332bfd567

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

PKG_BUILD_DEPENDS :=
MAKE_OPTS:=

include $(INCLUDE_DIR)/package.mk

define KernelPackage/qca-nss-ppe-netlink
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=PPE netlink Manager
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +kmod-qca-nss-ppe +kmod-qca-nss-ppe-rule @!LINUX_3_18
  FILES:=$(PKG_BUILD_DIR)/netlink/qca-nss-ppe-netlink.ko
  AUTOLOAD:=$(call AutoLoad,53,qca-nss-ppe-netlink)
endef

define KernelPackage/qca-nss-ppe-netlink/Description
Kernel module for PPE netlink manager
endef

#TODO: Resolve the unnecessary dependency on ssdk

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe \
	-I$(STAGING_DIR)/usr/include/qca-ssdk \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/fal \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/init

MAKE_OPTS+=netlink=y

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
endef

define Build/InstallDev/qca-nss-ppe-netlink
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-ppe
	$(CP) $(PKG_BUILD_DIR)/netlink/include/* $(1)/usr/include/qca-nss-ppe/
endef

define Build/InstallDev
	$(call Build/InstallDev/qca-nss-ppe-netlink,$(1))
endef

$(eval $(call KernelPackage,qca-nss-ppe-netlink))
