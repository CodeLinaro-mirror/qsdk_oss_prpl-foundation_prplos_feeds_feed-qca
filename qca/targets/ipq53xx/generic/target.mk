SUBTARGET:=generic
BOARDNAME:=QTI IPQ53xx(64bit) based boards
CPU_TYPE:=cortex-a53
KERNELNAME:=Image dtbs

define Target/Description
	Build images for ipq53xx 64 bit system.
endef

DEFAULT_PACKAGES += \
	sysupgrade-helper
