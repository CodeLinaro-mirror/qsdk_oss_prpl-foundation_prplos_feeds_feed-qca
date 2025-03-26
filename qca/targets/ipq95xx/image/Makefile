include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Device/Default
	PROFILES := Default
	KERNEL_LOADADDR := 0x40000000
	DEVICE_DTS = $$(SOC)-$(lastword $(subst _, ,$(1)))
	DEVICE_DTS_CONFIG := config@1
	DTS_DIR := $(DTS_DIR)/qcom
	IMAGES := sysupgrade.bin
	IMAGE/sysupgrade.bin = sysupgrade-tar | append-metadata
	IMAGE/sysupgrade.bin/squashfs :=
endef


define Device/MultiDTBFitImage
	KERNEL_SUFFIX := -fit-uImage.itb
	KERNEL = kernel-bin | lzma | MultiDTBFIT
	DEVICE_DTS =
	KERNEL_INITRAMFS =
endef

include $(SUBTARGET).mk

FindDeviceTrees ?= $(notdir $(basename $(shell find $(DTS_DIR)/ -name $(1)*.dtb $(2) 2>/dev/null)))

define Build/MkFITMulti
	$(TOPDIR)/scripts/mkits.sh \
		-D $(1) -o $(KDIR)/fit-$(1).its -k $(2) $(foreach dtb,$(subst \",,$(3)), -d $(DTS_DIR)/$(dtb).dtb$(if $(7),.gz)) -C $(4) -a $(5) -e $(6) $(if $(7),-x $(7) -l $(8))\
		-A $(LINUX_KARCH) -v $(LINUX_VERSION)
	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -f $(KDIR)/fit-$(1).its $(KDIR)/$(1)$(KERNEL_SUFFIX)
endef

define Build/MultiDTBFIT
	$(call Build/MkFITMulti,qcom_alxx,$@,$(call FindDeviceTrees, ipq9574-), lzma, $(KERNEL_LOADADDR),$(KERNEL_LOADADDR))
	mkdir -p $(BIN_DIR)/debug/modules
	mkdir -p $(BIN_DIR)/dtbs
	$(CP) $(STAGING_DIR_ROOT)/lib/modules/$(LINUX_VERSION)*/* $(BIN_DIR)/debug/modules/
	$(CP) $(KDIR)/vmlinux.debug $(BIN_DIR)/$(IMG_PREFIX)-vmlinux.elf
	$(CP) $(KDIR)/vmlinux-initramfs.debug $(BIN_DIR)/$(IMG_PREFIX)-vmlinux-initramfs.elf
	$(CP) $(KDIR)/Image* $(BIN_DIR)/dtbs/
	$(CP) $(DTS_DIR)/ipq95*.dtb $(BIN_DIR)/dtbs/
endef

$(eval $(call BuildImage))
