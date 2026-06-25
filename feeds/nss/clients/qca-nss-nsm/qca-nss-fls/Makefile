include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-fls
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r37
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-nsm
PKG_MIRROR_HASH:=dfa3b4d1c5350a6d04637ddc8e1450b0cb7e0b4bafb85c1d0804898fd4f0714b
PKG_VERSION:=65764f0d60f2fabc1323a171058813fc3826b964

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx +kmod-qca-nss-sfe +kmod-qca-nss-ecm
  TITLE:=Flow Statistics
  FILES:=$(PKG_BUILD_DIR)/fls/qca-nss-fls.ko
endef

define KernelPackage/$(PKG_NAME)/Description
Flow Identification
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/qca-nss-fls
	$(CP) $(PKG_BUILD_DIR)/fls/*.h $(STAGING_DIR)/usr/include/qca-nss-fls/
endef

EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-dp
EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-sfe
EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-ecm
EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/qca-nss-ppe

ifneq ($(CONFIG_PACKAGE_kmod-emesh-sp),)
FLS_MAKE_OPTS+=FLS_ECM_CLASSIFIER_EMESH_ENABLE=y
endif

ifeq ($(CONFIG_KERNEL_IPQ_MEM_PROFILE),512)
FLS_MAKE_OPTS+=FLS_MEM_PROFILE_512=y
endif

define Build/Compile
	$(KERNEL_MAKE) $(strip $(FLS_MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)/fls" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
