include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-nsm
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r29
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-nsm
PKG_MIRROR_HASH:=01d2d3405e494b8303ab386dd1390ab65d7fccbb54fed03cda520d3b42d0b571
PKG_VERSION:=abbc06f9b4bad26d7abfaf0ab53d49c730abc98a

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq95xx_32||TARGET_ipq53xx||TARGET_ipq53xx_32||TARGET_ipq54xx||TARGET_ipq96xx||TARGET_ipq52xx +kmod-qca-nss-sfe +kmod-qca-nss-ppe +kmod-qca-nss-dp
  TITLE:=Network Status Module
  FILES:=$(PKG_BUILD_DIR)/qca-nss-nsm.ko
endef

define KernelPackage/$(PKG_NAME)/Description
Network status module
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/qca-nss-nsm
	$(CP) $(PKG_BUILD_DIR)/exports/* $(STAGING_DIR)/usr/include/qca-nss-nsm/
endef

EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-nsm
EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-sfe
EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-ppe
EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-dp

define Build/Compile
	$(KERNEL_MAKE) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
