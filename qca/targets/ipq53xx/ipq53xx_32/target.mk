
ARCH:=arm
SUBTARGET:=ipq53xx_32
BOARDNAME:=QTI IPQ53xx(32bit) based boards
CPU_TYPE:=cortex-a7

define Target/Description
	Build firmware image for IPQ53xx SoC devices.
endef

DEFAULT_PACKAGES += \
	sysupgrade-helper
