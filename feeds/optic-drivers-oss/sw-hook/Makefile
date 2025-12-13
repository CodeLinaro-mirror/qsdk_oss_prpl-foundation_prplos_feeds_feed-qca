include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=sw-hook
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.pon.1.0.r30
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/trex/sw-hook
PKG_MIRROR_HASH:=skip
PKG_VERSION:=3edf3086b78b9ee5b3a78656739ed3672ca5f2fb

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=OPTIC_DRIVERS
  CATEGORY:=OptiCore Packages
  SUBMENU:=Drivers
  DEPENDS:=@TARGET_ipq53xx||TARGET_ipq95xx||TARGET_ipq54xx
  TITLE:=swhook
endef

define Package/$(PKG_NAME)/description
  sw hook
endef

EXTRA_CFLAGS += -Wno-implicit-fallthrough

MAKE_FLAGS+= \
	     CHIPSET="QCA" \
	     ARCH=$(LINUX_KARCH) \
	     SWHOOK_PLATFORM=qca \
	     CONFIG_SWHOOK_PLATFORM=$(SWHOOK_PLATFORM) \
	     K_SRC=$(LINUX_DIR) \
	     OMCIIBC_DIR=$(PKG_BUILD_DIR) \
	     TOOLPREFIX=$(TARGET_CROSS)

define Build/Compile
	$(KERNEL_MAKE)  \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		CHIPSET="QCA" \
		SWHOOK_PLATFORM=qca \
		CONFIG_SWHOOK_PLATFORM=$(SWHOOK_PLATFORM) \
		OMCIIBC_DIR=$(PKG_BUILD_DIR) \
		modules
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/sw-hook
	$(CP) $(PKG_BUILD_DIR)/Module.symvers $(STAGING_DIR)/usr/include/sw-hook
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib/modules/$(LINUX_UNAME_VERSION)
	$(CP) $(PKG_BUILD_DIR)/*.ko $(1)/lib/modules/$(LINUX_UNAME_VERSION)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
