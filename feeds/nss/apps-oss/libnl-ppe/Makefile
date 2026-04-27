include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=libnl-ppe
PKG_LICENSE:=ISC
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r37
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/nss-userspace
PKG_MIRROR_HASH:=skip
PKG_VERSION:=9c5a44c82e068eb751e994721ce2eb9c716d0ce5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_BUILD_DEPENDS:=qca-nss-ppe-netlink

include $(INCLUDE_DIR)/package.mk

define Package/libnl-ppe
  SECTION:=Libs
  CATEGORY:=Libraries
  TITLE:=Library to facilitate communication from user to kernel for the PPE netlink families
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq96xx||TARGET_ipq53xx||TARGET_ipq54xx||TARGET_ipq52xx +libpthread +libnl +kmod-qca-nss-ppe-netlink
endef

define Package/libnl-ppe/description
 Library to facilitate communication from user to kernel for the PPE netlink families.
endef

TOOL_CFLAGS:= -I$(STAGING_DIR)/usr/include/qca-nss-ppe \
              -I$(STAGING_DIR)/usr/include/libnl3

ifeq ($(CONFIG_TARGET_ipq96xx)$(CONFIG_TARGET_ipq52xx), y)
TOOL_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-dp
endif

TOOL_LDFLAGS:= -L$(STAGING_DIR)/ppenl_lib

ifeq ($(CONFIG_TARGET_ipq),y)
subtarget:=$(SUBTARGET)
else
subtarget:=$(CONFIG_TARGET_BOARD)
endif

ifneq ($(CONFIG_TARGET_ipq52xx)$(CONFIG_TARGET_ipq96xx),)
ifneq ($(CONFIG_KERNEL_IPQ_MEM_PROFILE),256)
ifneq ($(CONFIG_LOWMEM_FLASH),y)
MAKE_OPTS+=PPE_TUN_RPS_ENABLED=y
endif
endif
endif

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/ppe/ppenl_lib \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR) " \
		CFLAGS="$(TOOL_CFLAGS)" \
		LD_LIBRARY_PATH="$(TOOL_LDFLAGS)" \
		SoC="$(subtarget)"
endef

#TODO: Remove of the following which is not being used
define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/libnl-ppe
	$(CP) $(PKG_BUILD_DIR)/ppe/ppenl_lib/obj/libnl-ppe.so $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/ppe/ppenl_lib/include/* $(STAGING_DIR)/usr/include/libnl-ppe
endef

define Package/libnl-ppe/install
	$(INSTALL_DIR) $(1)/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ppe/ppenl_lib/obj/libnl-ppe.so $(1)/lib
endef

$(eval $(call BuildPackage,libnl-ppe))
