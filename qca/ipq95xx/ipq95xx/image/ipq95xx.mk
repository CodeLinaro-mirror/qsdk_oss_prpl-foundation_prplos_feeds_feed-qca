KERNEL_LOADADDR := 0x42080000

define Device/prpl_freedom
  DEVICE_TITLE := prpl Freedom
  DEVICE_DTS := ipq9574-freedom
  DEVICE_DTS_CONFIG := config@al02-c4
  SUPPORTED_DEVICES := prpl,freedom
endef
TARGET_DEVICES += prpl_freedom
