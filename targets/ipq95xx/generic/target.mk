
SUBTARGET:=generic
BOARDNAME:=QTI IPQ95xx(64bit) based boards
CPU_TYPE:=cortex-a73
KERNELNAME:=Image dtbs

define Target/Description
	Build images for IPQ95xx 64 bit system.
endef

DEFAULT_PACKAGES += \
	uboot-ipq9574-mmc uboot-ipq9574-norplusmmc \
	uboot-ipq9574-norplusnand uboot-ipq9574-nand \
	uboot-ipq9574-debug-mmc uboot-ipq9574-debug-norplusmmc \
	uboot-ipq9574-debug-norplusnand uboot-ipq9574-debug-nand \
	uboot-2025-ipq9574-mmc \
	uboot-2025-ipq9574-norplusmmc \
	uboot-2025-ipq9574-norplusnand \
	uboot-2025-ipq9574-nand \
	uboot-2025-ipq9574-debug-mmc \
	uboot-2025-ipq9574-debug-norplusmmc \
	uboot-2025-ipq9574-debug-norplusnand \
	uboot-2025-ipq9574-debug-nand \
	sysupgrade-helper
