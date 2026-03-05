include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=u-boot-freedom
PKG_VERSION:=FEAT-29
PKG_SOURCE_VERSION:=FEAT-29
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.com/prpl-foundation/platform/qualcomm/u-boot-qca-freedom.git

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_FILE_DEPENDS:=patches
CONFIG_NAME := ipq9574_wnc_freedom_mmc

include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
	BUILD_TARGET:=ipq95xx
	BUILD_SUBTARGET:=ipq95xx
	NAME:=Qualcomm IPQ9574 WNC Freedom
	BUILD_DEVICES:=wnc_freedom
endef

define Package/u-boot-freedom
	SECTION:=boot
	CATEGORY:=Boot Loaders
	DEPENDS:=@TARGET_ipq95xx
	TITLE:=U-Boot for Qualcomm IPQ9574 WNC Freedom
endef

define Build/Configure
	$(MAKE) -f Makefile -C $(PKG_BUILD_DIR) \
	    $(CONFIG_NAME)_defconfig \
	    CROSS_COMPILE=$(TARGET_CROSS) \
	    TARGETCC=$(TARGET_CC)
endef

define Build/Compile
	VERSION_CODE='$(VERSION_NICK) $(VERSION_NUMBER)' \
	REVISION='$(REVISION)' \
	LD_LIBRARY_PATH=$(STAGING_DIR_HOST)/lib:$(LD_LIBRARY_PATH) \
	KBUILD_VERBOSE=1 $(MAKE) -f Makefile -C $(PKG_BUILD_DIR) \
	HOSTSTRIP=true \
	CROSS_COMPILE=$(TARGET_CROSS) \
	TARGETCC="$(TARGET_CC)" \
	KCPPFLAGS="$(KCPPFLAGS)" \
	KCFLAGS=-Werror \
	HOSTLDFLAGS="$(HOST_LDFLAGS) -pthread -Werror" \
	HOSTCFLAGS="$(HOST_CFLAGS)" \
	DTC=${LINUX_DIR}/scripts/dtc/dtc \
	QCA_ELF=1 \
	all
endef

OBJCOPY:=$(TARGET_CROSS)objcopy

define Package/u-boot-freedom/install
	$(INSTALL_DIR) $(BIN_DIR)
	$(OBJCOPY) $(PKG_BUILD_DIR)/u-boot $(PKG_BUILD_DIR)/u-boot-dtb
	$(OBJCOPY) $(PKG_BUILD_DIR)/u-boot-dtb --set-section-flags .dtb=CONTENTS,ALLOC,DATA --update-section .dtb=$(PKG_BUILD_DIR)/fit-dtb.blob.lzo
	$(CP) $(PKG_BUILD_DIR)/u-boot.elfmbn $(BIN_DIR)/openwrt-ipq9574-$(SUBTARGET)-u-boot.elfmbn
endef

$(eval $(call BuildPackage,u-boot-freedom))
