SUBTARGET:=generic
BOARDNAME:=QTI IPQ53xx(64bit) based boards
CPU_TYPE:=cortex-a53
KERNELNAME:=Image dtbs

define Target/Description
	Build images for ipq53xx 64 bit system.
endef

DEFAULT_PACKAGES += \
	uboot-ipq5332-mmc uboot-ipq5332-norplusmmc \
	uboot-ipq5332-norplusnand uboot-ipq5332-nand \
	uboot-ipq5332-debug-mmc uboot-ipq5332-debug-norplusmmc \
	uboot-ipq5332-debug-norplusnand uboot-ipq5332-debug-nand \
	uboot-2025-ipq5332-mmc \
	uboot-2025-ipq5332-norplusmmc \
	uboot-2025-ipq5332-norplusnand \
	uboot-2025-ipq5332-nand \
	uboot-2025-ipq5332-debug-mmc \
	uboot-2025-ipq5332-debug-norplusmmc \
	uboot-2025-ipq5332-debug-norplusnand \
	uboot-2025-ipq5332-debug-nand \
	sysupgrade-helper
