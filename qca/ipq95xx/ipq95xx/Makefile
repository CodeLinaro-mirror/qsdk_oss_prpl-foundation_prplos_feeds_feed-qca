include $(TOPDIR)/rules.mk

ARCH:=aarch64
BOARD:=ipq95xx
BOARDNAME:=Qualcomm Technologies, Inc IPQ95xx
FEATURES:=squashfs fpu ramdisk nand pcie usbgadget
CPU_TYPE:=cortex-a73
CPU_SUBTYPE:=neon-vfpv4
MAINTAINER:=John Crispin <blogic@openwrt.org>
SUBTARGETS:=generic

KERNELNAME:=zImage Image dtbs

KERNEL_PATCHVER:=5.4
KERNEL_NAME_SUFFIX=-qsdk-f2ee796db820cd8261889849f043c9c816196452

include $(INCLUDE_DIR)/target.mk
DEFAULT_PACKAGES += \
	uboot-envtools kmod-leds-gpio kmod-gpio-button-hotplug kmod-button-hotplug \
	kmod-ata-core kmod-ata-ahci kmod-ata-ahci-platform kmod-usb3 swconfig \
	kmod-usb-phy-ipq807x kmod-usb-dwc3-qcom-internal \
	kmod-qca-nss-ppe kmod-qca-ssdk-qca-nohnat kmod-qca-psdk \
	kmod-qca-nss-dp-qca kmod-qca-nss-ppe-bridge-mgr kmod-qca-nss-ppe-vlan-mgr \
	kmod-gpio-button-hotplug iwinfo uboot-envtools swconfig \
	kmod-ath12k-qca ath12k-firmware-qcn92xx e2fsprogs kmod-fs-ext4 losetup

GENERIC_LINUX_CONFIG = $(PLATFORM_DIR)/generic/config-$(KERNEL_PATCHVER)-platform

define Kernel/Prepare
	$(call Kernel/Prepare/Default)
                                                                             
	$(if $(QUILT),rm -rf $(LINUX_DIR)/patches; mkdir -p $(LINUX_DIR)/patches)
	$(if $(FILES_DIR),$(CP) $(FILES_DIR)/* $(LINUX_DIR)/)
	find $(LINUX_DIR)/ -name \*.rej -or -name \*.orig | $(XARGS) rm -f
	$(call PatchDir,$(LINUX_DIR),$(PATCH_DIR),platform/)

	$(if $(QUILT),touch $(LINUX_DIR)/.quilt_used)
endef

$(eval $(call BuildTarget))
