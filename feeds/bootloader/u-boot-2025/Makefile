include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=u-boot-2025
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/boot/u-boot-2025
PKG_SOURCE_VERSION:=2b134826829e7e3af759cea7fe2529d334e183db
PKG_BRANCH:=win.uboot.2025.00.r37
PKG_RELEASE:=1
PKG_VERSION:=2b134826
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.zst
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

## repository for ipq files
PKG_FILES_NAME:=uboot-ipq-files
PKG_FILES_SOURCE_PROTO:=git
PKG_FILES_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/boot/uboot-ipq-files
PKG_FILES_SOURCE_VERSION:=eed8d4c6425b17d73ba55298314b9002c4d5eb93
PKG_FILES_BRANCH:=win.uboot.2025.00.r37
PKG_FILES_VERSION:=eed8d4c6

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_FILES_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_FILES_NAME)-$(PKG_FILES_VERSION)

CONFIG_NAME=$(shell echo $(BUILD_VARIANT) | sed 's/.*-//')
DEBUG_NAME=$(shell echo $(BUILD_VARIANT) | sed 's/-.*//')
SRC_DIR:=$(TOPDIR)/qca/src/$(PKG_NAME)
LOCAL_VARIANT=$(patsubst ipq9574_%,%,\
	$(patsubst ipq5332_%,%,\
	$(patsubst ipq5424_%,%,\
	$(patsubst ipq5210_%,%,\
	$(patsubst ipq9650_%,%,\
	$(BUILD_VARIANT) \
	)))))
TARGET_64BIT:=generic

# copy files after download
BOOTLOADER_FILES_SRC := $(PKG_FILES_BUILD_DIR)/*

VERSION_FILE := $(TOPDIR)/version
ifneq ($(wildcard $(VERSION_FILE)),)
	NHSS_VERSION := $(shell awk -F. 'NF == 4 { \
		if (length($$2) > 1) \
			print $$1 "." substr($$2, 1, 1) "." substr($$2, 2) "-" $$4; \
		else \
			print $$1 "." $$2 "-" $$4; \
	}' $(VERSION_FILE))
else
  $(warning Version file $(VERSION_FILE) not found, skipping version update)
endif

ifeq ($(SUBTARGET), generic)
    ARCH:=elf64-littleaarch64
else
    ARCH:=elf32-littlearm
endif
LD_SCRIPT_NAME:=u-boot-$(SUBTARGET)-custom.ld

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	$(call Build/Prepare/Default)
	# Clone uboot-ipq-files if not already present
	@echo "Preparing uboot-ipq-files repository..."
	if [ ! -d "$(PKG_FILES_BUILD_DIR)/.git" ]; then \
		rm -rf $(PKG_FILES_BUILD_DIR); \
		mkdir -p $(PKG_FILES_BUILD_DIR); \
		git clone --branch $(PKG_FILES_BRANCH) $(PKG_FILES_SOURCE_URL) $(PKG_FILES_BUILD_DIR); \
		cd $(PKG_FILES_BUILD_DIR) && git checkout $(PKG_FILES_SOURCE_VERSION); \
	fi
	# Copy bootloader files to build directory
	@echo "Copying bootloader files to build directory..."
	if [ -d "$(PKG_FILES_BUILD_DIR)" ]; then \
		cp -fpR $(BOOTLOADER_FILES_SRC) $(PKG_BUILD_DIR)/ 2>/dev/null || true; \
	fi
	# Also copy to source directory if it exists
	if [ -d "$(SRC_DIR)" ] && [ -d "$(PKG_FILES_BUILD_DIR)" ]; then \
		cp -fpR $(BOOTLOADER_FILES_SRC) $(SRC_DIR)/ 2>/dev/null || true; \
	fi
endef


ifeq ($(CONFIG_LINUX_6_1),y)
KCPPFLAGS += \
	-Wno-error=maybe-uninitialized \
	-Wno-error=address-of-packed-member \
	-Wno-error=attributes \
	-Wno-error=misleading-indentation
endif

define Build/Configure/debug
	echo "CONFIG_SKIP_RESET=y" >> $(PKG_BUILD_DIR)/configs/$(CONFIG_NAME)_defconfig;
endef

define Update/version
	if [ "$(NHSS_VERSION)" != "" ]; then \
		sed -i '/^SUBLEVEL =/s/.*/SUBLEVEL = '"$(NHSS_VERSION)"'/' $(PKG_BUILD_DIR)/Makefile; \
		sed -i 's/\.\$$$$(SUBLEVEL)/-\$$$$(SUBLEVEL)/g' $(PKG_BUILD_DIR)/Makefile; \
	fi
endef

define Packing/elf
	$(INSTALL_DIR) $(BIN_DIR)
	@$(CURDIR)/pack_elf.sh "$(PKG_BUILD_DIR)" "$(CONFIG_NAME)" "$(LD_SCRIPT_NAME)" "$(ARCH)" "$(OBJCOPY)" "$(LD)" "$(BIN_DIR)" "$(SUBTARGET)" "$(1)" "$(2)"
	$(CP) $(PKG_BUILD_DIR)/u-boot $(BIN_DIR)/openwrt-$(1)-$(SUBTARGET)-$(2)-u-boot-unstripped.elf
	$(CP) $(PKG_BUILD_DIR)/u-boot $(BIN_DIR)/openwrt-$(1)-$(SUBTARGET)-$(2)-u-boot-stripped.elf
	$(STRIP) $(BIN_DIR)/openwrt-$(1)-$(SUBTARGET)-$(2)-u-boot-stripped.elf
	$(CP) $(PKG_BUILD_DIR)/u-boot.bin $(BIN_DIR)/openwrt-$(1)-$(SUBTARGET)-$(2)-u-boot.img
endef

define Packing/spl_elf
	$(INSTALL_DIR) $(BIN_DIR)
	@echo "$(SPL_LD_SCRIPT)" > $(PKG_BUILD_DIR)/$(SPL_LD_SCRIPT_NAME)
	$(OBJCOPY) -I binary -O $(ARCH) --change-addresses $(SPL_TEXT_BASE) --set-start $(SPL_TEXT_BASE) $(PKG_BUILD_DIR)/spl/u-boot-spl.bin $(PKG_BUILD_DIR)/spl/u-boot-spl.o
	$(LD) $(PKG_BUILD_DIR)/spl/u-boot-spl.o -T $(PKG_BUILD_DIR)/$(SPL_LD_SCRIPT_NAME)  -o $(BIN_DIR)/u-boot-spl.elf
	$(CP) $(PKG_BUILD_DIR)/spl/u-boot-spl $(BIN_DIR)/u-boot-spl-unstripped.elf
	$(CP) $(PKG_BUILD_DIR)/spl/u-boot-spl $(BIN_DIR)/u-boot-spl-stripped.elf
	$(STRIP) $(BIN_DIR)/u-boot-spl-stripped.elf
	$(CP) $(PKG_BUILD_DIR)/spl/u-boot-spl.bin $(BIN_DIR)/u-boot-spl.img
endef

define Build/Configure
	$(call Build/Configure/$(DEBUG_NAME))
	$(call Update/version)
	$(MAKE) -C $(PKG_BUILD_DIR) $(CONFIG_NAME)_defconfig CROSS_COMPILE=$(TARGET_CROSS) TARGETCC=$(TARGET_CC);
endef

define Build/Compile
	VERSION_CODE='$(VERSION_NICK) $(VERSION_NUMBER)' \
	REVISION='$(REVISION)' \
	KBUILD_VERBOSE=1 $(MAKE) -C $(PKG_BUILD_DIR) HOSTSTRIP=true CROSS_COMPILE=$(TARGET_CROSS) \
		TARGETCC=$(TARGET_CC) \
		KCPPFLAGS="$(KCPPFLAGS)" \
		KCFLAGS=-Werror \
		HOSTLDFLAGS="$(HOST_LDFLAGS) -pthread -Werror" \
		HOSTCFLAGS="$(HOST_CFLAGS)" \
		DTC=${LINUX_DIR}/scripts/dtc/dtc \
		all
endef

OBJCOPY:=$(TARGET_CROSS)objcopy
LD:=$(TARGET_CROSS)ld

define Package/uboot-2025-ipq5332-debug/common
  define Package/uboot-2025-ipq5332-debug-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    DEPENDS:=@TARGET_ipq53xx
    TITLE:=U-boot for IPQ5322 $(1)
    URL:=http://www.denx.de/wiki/U-Boot
    VARIANT:=debug-ipq5332_$(1)
  endef
endef

define Package/uboot-2025-ipq5332-debug
  $(call Package/uboot-2025-ipq5332-debug/common,$(1),$(2))

  define Package/uboot-2025-ipq5332-debug-$(1)/install
	$(call Packing/elf,ipq5332,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq5332-debug-$(1)))
endef

define Package/uboot-2025-ipq5332/common
  define Package/uboot-2025-ipq5332-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    DEPENDS:=@TARGET_ipq53xx
    TITLE:=U-boot for IPQ5322 $(1)
    URL:=http://www.denx.de/wiki/U-Boot
    VARIANT:=ipq5332_$(1)
  endef
endef

define Package/uboot-2025-ipq5332
  $(call Package/uboot-2025-ipq5332/common,$(1),$(2))

  define Package/uboot-2025-ipq5332-$(1)/install
	$(call Packing/elf,ipq5332,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq5332-$(1)))
endef

define Package/uboot-2025-ipq9574-debug/common
  define Package/uboot-2025-ipq9574-debug-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    DEPENDS:=@TARGET_ipq95xx
    TITLE:=U-boot for IPQ9574 $(1)
    URL:=http://www.denx.de/wiki/U-Boot
    VARIANT:=debug-ipq9574_$(1)
  endef
endef

define Package/uboot-2025-ipq9574-debug
  $(call Package/uboot-2025-ipq9574-debug/common,$(1),$(2))

  define Package/uboot-2025-ipq9574-debug-$(1)/install
	$(call Packing/elf,ipq9574,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq9574-debug-$(1)))
endef

define Package/uboot-2025-ipq9574/common
  define Package/uboot-2025-ipq9574-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    DEPENDS:=@TARGET_ipq95xx
    TITLE:=U-boot for IPQ9574 $(1)
    URL:=http://www.denx.de/wiki/U-Boot
    VARIANT:=ipq9574_$(1)
  endef
endef

define Package/uboot-2025-ipq9574
  $(call Package/uboot-2025-ipq9574/common,$(1),$(2))

  define Package/uboot-2025-ipq9574-$(1)/install
	$(call Packing/elf,ipq9574,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq9574-$(1)))
endef

define Package/uboot-2025-ipq5424-debug/common
  define Package/uboot-2025-ipq5424-debug-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    DEPENDS:=@TARGET_ipq54xx
    TITLE:=U-boot for IPQ5424 $(1)
    URL:=http://www.denx.de/wiki/U-Boot
    VARIANT:=debug-ipq5424_$(1)
  endef
endef

define Package/uboot-2025-ipq5424-debug
  $(call Package/uboot-2025-ipq5424-debug/common,$(1),$(2))

  define Package/uboot-2025-ipq5424-debug-$(1)/install
	$(call Packing/elf,ipq5424,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq5424-debug-$(1)))
endef

define Package/uboot-2025-ipq5424/common
  define Package/uboot-2025-ipq5424-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    DEPENDS:=@TARGET_ipq54xx
    TITLE:=U-boot for IPQ5424 $(1)
    URL:=http://www.denx.de/wiki/U-Boot
    VARIANT:=ipq5424_$(1)
  endef
endef

define Package/uboot-2025-ipq5424
  $(call Package/uboot-2025-ipq5424/common,$(1),$(2))

  define Package/uboot-2025-ipq5424-$(1)/install
	$(call Packing/elf,ipq5424,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq5424-$(1)))
endef

define Package/uboot-2025-ipq5210/common
  define Package/uboot-2025-ipq5210-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    DEPENDS:=@TARGET_ipq52xx
    TITLE:=U-boot for IPQ5210 $(1)
    URL:=http://www.denx.de/wiki/U-Boot
    VARIANT:=ipq5210_$(1)
  endef
endef

define Package/uboot-2025-ipq5210-spl
  $(call Package/uboot-2025-ipq5210/common,spl)

  define Package/uboot-2025-ipq5210-spl/install
       $(call Packing/spl_elf,ipq5210,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq5210-spl))
endef

define Package/uboot-2025-ipq5210
  $(call Package/uboot-2025-ipq5210/common,$(1),$(2))

  define Package/uboot-2025-ipq5210-$(1)/install
	$(call Packing/elf,ipq5210,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq5210-$(1)))
endef

define Package/uboot-2025-ipq9650/common
  define Package/uboot-2025-ipq9650-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    DEPENDS:=@TARGET_ipq96xx
    TITLE:=U-boot for IPQ9650 $(1)
    URL:=http://www.denx.de/wiki/U-Boot
    VARIANT:=ipq9650_$(1)
  endef
endef

define Package/uboot-2025-ipq9650
  $(call Package/uboot-2025-ipq9650/common,$(1),$(2))

  define Package/uboot-2025-ipq9650-$(1)/install
	$(call Packing/elf,ipq9650,$(LOCAL_VARIANT))
  endef

  $$(eval $$(call BuildPackage,uboot-2025-ipq9650-$(1)))
endef

$(eval $(call Package/uboot-2025-ipq5332,mmc))
$(eval $(call Package/uboot-2025-ipq5332,mmc32))
$(eval $(call Package/uboot-2025-ipq5332,nand))
$(eval $(call Package/uboot-2025-ipq5332,nand32))
$(eval $(call Package/uboot-2025-ipq5332,norplusnand))
$(eval $(call Package/uboot-2025-ipq5332,norplusnand32))
$(eval $(call Package/uboot-2025-ipq5332,norplusmmc))
$(eval $(call Package/uboot-2025-ipq5332,norplusmmc32))
$(eval $(call Package/uboot-2025-ipq5332,tiny_nand32))
$(eval $(call Package/uboot-2025-ipq5332,tiny_v2_nand32))
$(eval $(call Package/uboot-2025-ipq5332,tiny_nand32_64M))
$(eval $(call Package/uboot-2025-ipq5332,tiny_v2_nand32_64M))
$(eval $(call Package/uboot-2025-ipq5332,tiny_nor32))
$(eval $(call Package/uboot-2025-ipq5332,tiny_norplusnand32))
$(eval $(call Package/uboot-2025-ipq5332,tiny_v2_norplusnand32))
$(eval $(call Package/uboot-2025-ipq5332-debug,mmc))
$(eval $(call Package/uboot-2025-ipq5332-debug,mmc32))
$(eval $(call Package/uboot-2025-ipq5332-debug,nand))
$(eval $(call Package/uboot-2025-ipq5332-debug,nand32))
$(eval $(call Package/uboot-2025-ipq5332-debug,norplusnand))
$(eval $(call Package/uboot-2025-ipq5332-debug,norplusnand32))
$(eval $(call Package/uboot-2025-ipq5332-debug,norplusmmc))
$(eval $(call Package/uboot-2025-ipq5332-debug,norplusmmc32))
$(eval $(call Package/uboot-2025-ipq5332-debug,tiny_nand32))
$(eval $(call Package/uboot-2025-ipq5332-debug,tiny_v2_nand32))
$(eval $(call Package/uboot-2025-ipq5332-debug,tiny_nand32_64M))
$(eval $(call Package/uboot-2025-ipq5332-debug,tiny_v2_nand32_64M))
$(eval $(call Package/uboot-2025-ipq5332-debug,tiny_nor32))
$(eval $(call Package/uboot-2025-ipq5332-debug,tiny_norplusnand32))
$(eval $(call Package/uboot-2025-ipq5332-debug,tiny_v2_norplusnand32))

$(eval $(call Package/uboot-2025-ipq9574,mmc))
$(eval $(call Package/uboot-2025-ipq9574,mmc32))
$(eval $(call Package/uboot-2025-ipq9574,nand))
$(eval $(call Package/uboot-2025-ipq9574,nand32))
$(eval $(call Package/uboot-2025-ipq9574,norplusnand))
$(eval $(call Package/uboot-2025-ipq9574,norplusnand32))
$(eval $(call Package/uboot-2025-ipq9574,norplusmmc))
$(eval $(call Package/uboot-2025-ipq9574,norplusmmc32))
$(eval $(call Package/uboot-2025-ipq9574-debug,mmc))
$(eval $(call Package/uboot-2025-ipq9574-debug,mmc32))
$(eval $(call Package/uboot-2025-ipq9574-debug,nand))
$(eval $(call Package/uboot-2025-ipq9574-debug,nand32))
$(eval $(call Package/uboot-2025-ipq9574-debug,norplusnand))
$(eval $(call Package/uboot-2025-ipq9574-debug,norplusnand32))
$(eval $(call Package/uboot-2025-ipq9574-debug,norplusmmc))
$(eval $(call Package/uboot-2025-ipq9574-debug,norplusmmc32))

$(eval $(call Package/uboot-2025-ipq5424,mmc))
$(eval $(call Package/uboot-2025-ipq5424,mmc32))
$(eval $(call Package/uboot-2025-ipq5424,nand))
$(eval $(call Package/uboot-2025-ipq5424,nand32))
$(eval $(call Package/uboot-2025-ipq5424,norplusnand))
$(eval $(call Package/uboot-2025-ipq5424,norplusnand32))
$(eval $(call Package/uboot-2025-ipq5424,norplusmmc))
$(eval $(call Package/uboot-2025-ipq5424,norplusmmc32))
$(eval $(call Package/uboot-2025-ipq5424,tiny_nand32))
$(eval $(call Package/uboot-2025-ipq5424,tiny_norplusnand32))
$(eval $(call Package/uboot-2025-ipq5424-debug,mmc))
$(eval $(call Package/uboot-2025-ipq5424-debug,mmc32))
$(eval $(call Package/uboot-2025-ipq5424-debug,nand))
$(eval $(call Package/uboot-2025-ipq5424-debug,nand32))
$(eval $(call Package/uboot-2025-ipq5424-debug,norplusnand))
$(eval $(call Package/uboot-2025-ipq5424-debug,norplusnand32))
$(eval $(call Package/uboot-2025-ipq5424-debug,norplusmmc))
$(eval $(call Package/uboot-2025-ipq5424-debug,norplusmmc32))
$(eval $(call Package/uboot-2025-ipq5424-debug,tiny_nand32))
$(eval $(call Package/uboot-2025-ipq5424-debug,tiny_norplusnand32))

$(eval $(call Package/uboot-2025-ipq5210,mmc))
$(eval $(call Package/uboot-2025-ipq5210,mmc32))
$(eval $(call Package/uboot-2025-ipq5210,nand))
$(eval $(call Package/uboot-2025-ipq5210,nand32))
$(eval $(call Package/uboot-2025-ipq5210,norplusnand))
$(eval $(call Package/uboot-2025-ipq5210,norplusnand32))
$(eval $(call Package/uboot-2025-ipq5210,norplusmmc))
$(eval $(call Package/uboot-2025-ipq5210,norplusmmc32))
$(eval $(call Package/uboot-2025-ipq5210,tiny_nand32))
$(eval $(call Package/uboot-2025-ipq5210,tiny_norplusnand32))
$(eval $(call Package/uboot-2025-ipq5210-spl))

$(eval $(call Package/uboot-2025-ipq9650,mmc))
$(eval $(call Package/uboot-2025-ipq9650,mmc32))
$(eval $(call Package/uboot-2025-ipq9650,nand))
$(eval $(call Package/uboot-2025-ipq9650,nand32))
$(eval $(call Package/uboot-2025-ipq9650,norplusnand))
$(eval $(call Package/uboot-2025-ipq9650,norplusnand32))
$(eval $(call Package/uboot-2025-ipq9650,norplusmmc))
$(eval $(call Package/uboot-2025-ipq9650,norplusmmc32))
