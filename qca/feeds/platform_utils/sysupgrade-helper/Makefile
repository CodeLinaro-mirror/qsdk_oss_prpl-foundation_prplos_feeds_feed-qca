include $(TOPDIR)/rules.mk

PKG_DISTNAME:=sysupgrade-helper
PKG_NAME:=u-boot
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/boot/u-boot
PKG_SOURCE_VERSION:=a258badb1d4e3cf7936046d49cb88bd20e66aa09
PKG_BRANCH:=win.coretech.3.0.r26
PKG_RELEASE:=1
PKG_VERSION:=a258badb
PKG_MIRROR_HASH:=c1196f20f9b456a3a3b6989277734c9567f0f374d4983c02c09cb7a372e27034

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_DISTNAME)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/sysupgrade-helper
  SECTION:=boot
  CATEGORY:=Boot Loaders
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +losetup +libopenssl
  TITLE:=U-boot images tools (dumpimage, mkimage)
endef

HOSTLDFLAGS = \
	      -L$(STAGING_DIR)/usr/lib \
	      -znow -zrelro -pie -Werror

ifneq ($(CONFIG_TARGET_ipq54xx),)
  IMG_FLAG = "-DIPQ54XX"
endif

SHA_FLAG = "-DUSE_SHA256"

ifneq ($(CONFIG_TARGET_ipq95xx)$(CONFIG_TARGET_ipq54xx),)
  SHA_FLAG = "-DUSE_SHA384"
endif

define Build/Configure
	mkdir -p $(PKG_BUILD_DIR)/include/config
	echo "CONFIG_FIT=y" >> $(PKG_BUILD_DIR)/include/config/auto.conf
	echo "CONFIG_FIT_PRINT=y" >> $(PKG_BUILD_DIR)/include/config/auto.conf
	echo "CONFIG_TOOLS_FIT=y" >> $(PKG_BUILD_DIR)/include/config/auto.conf
	echo "CONFIG_TOOLS_FIT_PRINT=y" >> $(PKG_BUILD_DIR)/include/config/auto.conf
	echo "CONFIG_SYSUPGRADE_HELPER=y" >> $(PKG_BUILD_DIR)/include/config/auto.conf
	touch $(PKG_BUILD_DIR)/include/config/auto.conf
	mkdir -p $(PKG_BUILD_DIR)/include/generated
	echo "#define CONFIG_FIT_PRINT 1" >> $(PKG_BUILD_DIR)/include/generated/autoconf.h
	echo "#define CONFIG_FIT 1" >> $(PKG_BUILD_DIR)/include/generated/autoconf.h
	echo "#define CONFIG_TOOLS_FIT 1" >> $(PKG_BUILD_DIR)/include/generated/autoconf.h
	echo "#define CONFIG_TOOLS_FIT_PRINT 1" >> $(PKG_BUILD_DIR)/include/generated/autoconf.h
	echo "#define CONFIG_SYSUPGRADE_HELPER 1" >> $(PKG_BUILD_DIR)/include/generated/autoconf.h
	touch $(PKG_BUILD_DIR)/include/generated/autoconf.h
endef

MAKE_FLAGS += \
	CROSS_BUILD_TOOLS=y \
	HOSTCFLAGS="$(SHA_FLAG) $(IMG_FLAG) -fPIC" \
	HOSTLDFLAGS="$(HOSTLDFLAGS) -lpthread -lcrypto -lssl" \
	HOSTEXTRACFLAGS="$(HOST_EXTRACFLAGS)" \
	no-dot-config-targets=tools-only \
	tools-only

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
endef

define Package/sysupgrade-helper/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/mkimage $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/dumpimage $(1)/usr/bin
endef

$(eval $(call BuildPackage,sysupgrade-helper))
