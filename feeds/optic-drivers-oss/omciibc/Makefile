include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=omciibc
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.pon.1.0.r37
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/trex/omciibc
PKG_MIRROR_HASH:=skip
PKG_VERSION:=39d494c081e00fb416054164db445d93c29782a1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=OPTIC_DRIVERS
  CATEGORY:=OptiCore Packages
  SUBMENU:=Drivers
  DEPENDS:=@TARGET_ipq53xx||TARGET_ipq95xx||TARGET_ipq54xx||TARGET_ipq96xx +kmod-qca-nss-dp +sw-hook
  TITLE:=omciibc ifp
endef

define Package/$(PKG_NAME)/description
  OMCIIBC IFP
endef

define Package/omciibc/config
source "$(SOURCE)/Config.in"
endef

EXTRA_CFLAGS += -Wno-implicit-fallthrough -Wno-incompatible-pointer-types

ifeq ("$(CONFIG_OMCIIBC_SWHOOK_ENABLE)", "y")
EXTRA_CFLAGS += -DOMCIIBC_SWHOOK_ENABLE
endif

MAKE_FLAGS+= \
	CHIPSET="QCA" \
	ARCH=$(LINUX_KARCH) \
	OMCIIBC_PLATFORM=qca \
	CONFIG_OMCIIBC_PLATFORM=$(OMCIIBC_PLATFORM) \
	K_SRC=$(LINUX_DIR) \
	OMCIIBC_DIR=$(PKG_BUILD_DIR) \
	TOOLPREFIX=$(TARGET_CROSS)

define Build/Compile
	$(KERNEL_MAKE)  \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		CHIPSET="QCA" \
		OMCIIBC_PLATFORM=qca \
		CONFIG_OMCIIBC_PLATFORM=$(OMCIIBC_PLATFORM) \
		OMCIIBC_DIR=$(PKG_BUILD_DIR) \
		modules
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/omciibc
	$(CP) $(PKG_BUILD_DIR)/omciibc.h $(STAGING_DIR)/usr/include/omciibc
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib/modules/$(LINUX_UNAME_VERSION)
	$(CP) $(PKG_BUILD_DIR)/*.ko $(1)/lib/modules/$(LINUX_UNAME_VERSION)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
