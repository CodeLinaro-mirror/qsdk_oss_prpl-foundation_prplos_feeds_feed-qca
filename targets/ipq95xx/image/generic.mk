
DTS_CPPFLAGS:=-D __CPU_THERMAL__

define Device/FitImage
	KERNEL_SUFFIX := -uImage.itb
	KERNEL = kernel-bin | libdeflate-gzip | fit gzip $$(KDIR)/image-$$(DEVICE_DTS).dtb
	KERNEL_NAME := Image
endef

define Device/EmmcImage
	IMAGES += factory.bin sysupgrade.bin
	IMAGE/factory.bin := append-rootfs | pad-rootfs | pad-to 64k
	IMAGE/sysupgrade.bin/squashfs := append-rootfs | pad-to 64k | sysupgrade-tar rootfs=$$$$@ | append-metadata
endef

define Device/qcom_alxx
        $(call Device/MultiDTBFitImage)
	DEVICE_VENDOR := Qualcomm Technologies, Inc.
	DEVICE_MODEL := AP-ALXX
	DEVICE_VARIANT :=
	BOARD_NAME := ap-alxx
	SOC := ipq9574
	KERNEL_INSTALL := 1
	KERNEL_SIZE := $(if $CONFIG_USE_PRPLMESH_WHM, $(if $(CONFIG_DEBUG),9216k,7400k), $(if $(CONFIG_DEBUG),9216k,7000k))
	IMAGE_SIZE := 25344k
	IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-rootfs | pad-rootfs | append-metadata
endef
TARGET_DEVICES += qcom_alxx

define Device/qcom_rdp433
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := Qualcomm
	DEVICE_MODEL := IPQ9574-RDP433
	DEVICE_DTS_CONFIG := config-rdp433
	SOC := ipq9574
	DEVICE_PACKAGES += kmod-ath12k \
		mkf2fs f2fsck kmod-fs-f2fs
endef
TARGET_DEVICES += qcom_rdp433

define Device/qcom_rdp433-mht-phy
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := Qualcomm
	DEVICE_MODEL := IPQ9574-RDP433-MHT-PHY
	DEVICE_DTS_CONFIG := config-rdp433-mht-phy
	SOC := ipq9574
	DEVICE_PACKAGES += kmod-ath12k \
		mkf2fs f2fsck kmod-fs-f2fs
endef
TARGET_DEVICES += qcom_rdp433-mht-phy

define Device/qcom_rdp475
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := Qualcomm
	DEVICE_MODEL := IPQ9574-RDP475
	DEVICE_DTS_CONFIG := config-rdp475
	SOC := ipq9574
	DEVICE_PACKAGES += kmod-ath12k \
		mkf2fs f2fsck kmod-fs-f2fs
endef
TARGET_DEVICES += qcom_rdp475

define Device/qcom_rdp476
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := Qualcomm
	DEVICE_MODEL := IPQ9574-RDP476
	DEVICE_DTS_CONFIG := config-rdp476
	SOC := ipq9574
	DEVICE_PACKAGES += kmod-ath12k \
		mkf2fs f2fsck kmod-fs-f2fs
endef
TARGET_DEVICES += qcom_rdp476

#define Device/prpl_freedom
#	$(call Device/FitImage)
#	$(call Device/EmmcImage)
#	DEVICE_VENDOR := Prpl
#	DEVICE_MODEL := Freedom
#	DEVICE_DTS := ipq9574-freedom
#	DEVICE_DTS_CONFIG := config@al02-c4
#	SOC := ipq9574
#	DEVICE_PACKAGES += ath12k-firmware-qcn92xx ath12k-wifi-qcom-qcn92xx kmod-ath12k \
#		mkf2fs f2fsck kmod-fs-f2fs
#endef
#TARGET_DEVICES += prpl_freedom
