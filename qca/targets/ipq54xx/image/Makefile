include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Device/Default
	PROFILES := Default
	KERNEL_LOADADDR := $(if $(CONFIG_TARGET_ipq54xx_generic),0x80000000,0x80008000)
	DTS_DIR := $(LINUX_DIR)/arch/$(LINUX_KARCH)/boot/dts/$(if $(CONFIG_LINUX_6_6)$(CONFIG_TARGET_ipq54xx_generic),qcom)
	KERNEL_DEPENDS = $$(wildcard $(DTS_DIR)/$$(DEVICE_DTS).dts)
	DEVICE_DTS = $$(SOC)-$(lastword $(subst _, ,$(1)))
	DEVICE_DTS_CONFIG := config-1
	DEVICE_DTS_DIR := $(DTS_DIR)/qcom
	IMAGES := sysupgrade.bin
	IMAGE/sysupgrade.bin = sysupgrade-tar | append-metadata
	IMAGE/sysupgrade.bin/squashfs :=
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))
