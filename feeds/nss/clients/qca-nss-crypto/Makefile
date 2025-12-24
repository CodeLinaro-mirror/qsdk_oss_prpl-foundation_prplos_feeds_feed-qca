include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-crypto
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r30
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-crypto
PKG_MIRROR_HASH:=b6692fd2d25f538a4734e77dcaa1640c5b5e70826ef2d9ff2fce024df5978296
PKG_VERSION:=60e27b91f9cdb1d6de38337c03444021ae8c1040

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_ipq),y)
subtarget:=$(SUBTARGET)
else
subtarget:=$(CONFIG_TARGET_BOARD)
endif

# v1.0 is for Akronite
# v2.0 is for Hawkeye/Cypress/Maple
ifneq (, $(findstring $(subtarget), "ipq95xx" "ipq95xx_32" "ipq807x" "ipq807x_64" "ipq60xx" "ipq60xx_64" "ipq50xx" "ipq50xx_64"))
NSS_CRYPTO_DIR:=v2.0
else
NSS_CRYPTO_DIR:=v1.0
endif

define KernelPackage/qca-nss-crypto/Default
SECTION:=kernel
CATEGORY:=Kernel modules
SUBMENU:=Network Devices
DEPENDS:=@TARGET_ipq806x||TARGET_ipq_ipq806x||TARGET_ipq_ipq807x||TARGET_ipq_ipq807x_64||TARGET_ipq807x||TARGET_ipq_ipq50xx||TARGET_ipq_ipq50xx_64||TARGET_ipq50xx||TARGET_ipq_ipq60xx||TARGET_ipq_ipq60xx_64||TARGET_ipq60xx||TARGET_ipq95xx||TARGET_ipq95xx_32 \
	@!LINUX_3_18
KCONFIG:=CONFIG_CRYPTO_DISABLE_AHASH_TYPE2_TESTS=y \
	 CONFIG_IPQ_PROFILE_MINENT=y
endef

define KernelPackage/qca-nss-crypto
  $(call KernelPackage/qca-nss-crypto/Default)
  TITLE:=Kernel driver for NSS crypto driver
  FILES:=$(PKG_BUILD_DIR)/$(NSS_CRYPTO_DIR)/src/qca-nss-crypto.ko \
	$(PKG_BUILD_DIR)/$(NSS_CRYPTO_DIR)/tool/qca-nss-crypto-tool.ko
  AUTOLOAD:=$(call AutoLoad,52,qca-nss-crypto)
endef

define KernelPackage/qca-nss-crypto/Description
This package contains a NSS crypto driver for QCA chipset
endef

define Build/InstallDev/qca-nss-crypto
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-crypto
	$(CP) $(PKG_BUILD_DIR)/$(NSS_CRYPTO_DIR)/include/* $(1)/usr/include/qca-nss-crypto
endef

# TODO: Remove this temporary WAR for LM256 compilation with ginger5.4,
# once the root cause is identified
ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-crypto),)
define Build/InstallDev
	$(call Build/InstallDev/qca-nss-crypto,$(1))
endef
endif

EXTRA_CFLAGS+= \
	-DCONFIG_NSS_DEBUG_LEVEL=4 \
	-I$(STAGING_DIR)/usr/include/qca-nss-crypto \
	-I$(STAGING_DIR)/usr/include/qca-nss-drv \
	-I$(PKG_BUILD_DIR)/$(NSS_CRYPTO_DIR)/include \
	-I$(PKG_BUILD_DIR)/$(NSS_CRYPTO_DIR)/src

define Build/Compile
	$(KERNEL_MAKE) \
		CC="$(TARGET_CC)" \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		NSS_CRYPTO_DIR=$(NSS_CRYPTO_DIR) \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-crypto))
