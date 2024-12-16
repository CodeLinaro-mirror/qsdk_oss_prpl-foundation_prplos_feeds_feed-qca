include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=libnl-ppe
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=NHSS.QSDK.12.5.5
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/nss-userspace
PKG_MIRROR_HASH:=skip
PKG_VERSION:=6460a3e5b987a9e4c15e345e6984c06355a8f2ee

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/libnl-ppe
  SECTION:=Libs
  CATEGORY:=Libraries
  TITLE:=Library to facilitate communication from user to kernel for the PPE netlink families
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx +libpthread +libnl +kmod-qca-nss-ppe-netlink
endef

define Package/libnl-ppe/description
 Library to facilitate communication from user to kernel for the PPE netlink families.
endef

TOOL_CFLAGS:= -I$(STAGING_DIR)/usr/include/qca-nss-ppe \
              -I$(STAGING_DIR)/usr/include/libnl3

TOOL_LDFLAGS:= -L$(STAGING_DIR)/ppenl_lib

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/ppe/ppenl_lib \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR) " \
		CFLAGS="$(TOOL_CFLAGS)" \
		LD_LIBRARY_PATH="$(TOOL_LDFLAGS)"
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
