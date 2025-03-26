include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=trex-drv
PKG_RELEASE:=1

include $(INCLUDE_DIR)/local-development.mk
ifeq ($(DUMP)$(PKG_VERSION),)
 PKG_REV:=$(shell git ls-remote $(PKG_SOURCE_URL) $(PKG_BRANCH) | cut -b -7)
 PKG_VERSION:=g$(PKG_REV)
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=OPTIC_DRIVERS
  CATEGORY:=OptiCore Packages
  SUBMENU:=Drivers
  DEPENDS:=+kmod-qca-nss-dp-qca +kmod-qca-ssdk-qca-nohnat +omciibc
  TITLE:=TREX SDK
endef

define Package/$(PKG_NAME)/description
  TREX SDK
endef

EXTRA_CFLAGS += -DARM64 -DCONFIG_IPQ807x_HK01 \
	-I$(PKG_BUILD_DIR)/trex_ifhost \
	-I$(PKG_BUILD_DIR)/trex_drv \
	-I$(PKG_BUILD_DIR)/trex_os \
	-I$(PKG_BUILD_DIR)/trex_otag \
	-I$(PKG_BUILD_DIR)/trex_iftrap \
	-Wno-implicit-fallthrough -Wno-error=address \
	-Wno-error=date-time -Wno-date-time \
	-I$(STAGING_DIR)/usr/include/qca-ssdk

TREX_PLATFORM=qca
MAKE_FLAGS+= \
	    $(KERNEL_MAKE_FLAGS) \
	    CHIPSET="QCA" \
	    ARCH=$(LINUX_KARCH) \
	    CPU=$(LINUX_KARCH) \
	    CONFIG_TREX_PLATFORM=$(TREX_PLATFORM) \
	    K_SRC=$(LINUX_DIR) \
	    SSDK_DIR=$(SSDK_DIR) \
	    TREX_DIR=$(PKG_BUILD_DIR) \
	    TOOLPREFIX=$(TARGET_CROSS) \
	    EXTRA_CFLAGS="$(EXTRA_CFLAGS)"

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/trex
	$(CP) $(PKG_BUILD_DIR)/**/*.h $(STAGING_DIR)/usr/include/trex
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/**/*.a $(STAGING_DIR)/usr/lib
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib/modules/$(LINUX_UNAME_VERSION)
	$(CP) $(PKG_BUILD_DIR)/**/*.ko $(1)/lib/modules/$(LINUX_UNAME_VERSION)
	[ ! -d $(1)/etc/omci ] && $(INSTALL_DIR) $(1)/etc/omci
	[ ! -d $(1)/etc/omci/vhcmd ] && $(INSTALL_DIR) $(1)/etc/omci/vhcmd
	$(CP) $(PKG_BUILD_DIR)/vhcmd/vhcmd $(1)/etc/omci/vhcmd
	$(CP) -f $(PKG_BUILD_DIR)/vhcmd/vhcmd.cli $(1)/etc/omci/vhcmd
	$(CP) -f $(PKG_BUILD_DIR)/vhcmd/vhcmd.help $(1)/etc/omci/vhcmd
	$(CP) -rf $(PKG_BUILD_DIR)/vhcmd/vh $(1)/etc/omci/vhcmd
	$(CP) -f $(PKG_BUILD_DIR)/script/trex_omciibc.sh $(1)/etc/omci/trex_omciibc.sh
	$(CP) -f $(PKG_BUILD_DIR)/script/trex.sh $(1)/etc/omci/trex.sh
	$(CP) -f $(PKG_BUILD_DIR)/script/trex_reset.sh $(1)/etc/omci/trex_reset.sh
	$(CP) -f $(PKG_BUILD_DIR)/script/trex_default.sh $(1)/etc/omci/trex_default.sh
	$(CP) -f $(PKG_BUILD_DIR)/script/trex_event.sh $(1)/etc/omci/trex_event.sh
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
