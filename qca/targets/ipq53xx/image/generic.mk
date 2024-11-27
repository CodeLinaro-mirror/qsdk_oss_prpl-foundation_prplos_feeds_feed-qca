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

define Device/qcom_rdp441
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := Qualcomm
	DEVICE_MODEL := RDP441
	DEVICE_DTS := ipq5332-rdp441
	DEVICE_DTS_CONFIG := config@mi01.2
	SOC := ipq5332
	DEVICE_PACKAGES += kmod-ath12k \
		mkf2fs f2fsck kmod-fs-f2fs
endef
TARGET_DEVICES += qcom_rdp441

define Device/qcom_rdp484
	$(call Device/FitImage)
	$(call Device/EmmcImage)
	DEVICE_VENDOR := Qualcomm
	DEVICE_MODEL := RDP484
	DEVICE_DTS := ipq5332-rdp484
	DEVICE_DTS_CONFIG := config-rdp484
	SOC := ipq5332
	DEVICE_PACKAGES += kmod-ath12k \
		mkf2fs f2fsck kmod-fs-f2fs
endef
TARGET_DEVICES += qcom_rdp484
