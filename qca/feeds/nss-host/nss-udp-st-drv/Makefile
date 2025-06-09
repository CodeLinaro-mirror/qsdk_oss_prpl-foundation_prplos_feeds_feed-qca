include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=nss-udp-st-drv
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r26
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-speedtest
PKG_MIRROR_HASH:=skip
PKG_VERSION:=fa1608a170f5b587a5dae2912d31614092691d21

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  DEPENDS:=@TARGET_ipq50xx||TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx \
		+TARGET_ipq53xx||TARGET_ipq95xx||TARGET_ipq54xx:kmod-qca-nss-ppe-vp \
		+TARGET_ipq53xx||TARGET_ipq95xx||TARGET_ipq54xx:kmod-qca-nss-ppe-tun \
		+kmod-pppoe
  TITLE:=Kernel driver for NSS UDP Speedtest
  FILES:=$(PKG_BUILD_DIR)/nss-udp-st-drv/nss-udp-st.ko
endef

define KernelPackage/$(PKG_NAME)/Description
Kernel driver for host data path NSS UDP speedtest
endef

define KernelPackage/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/nss-udp-st-drv
	$(CP) $(PKG_BUILD_DIR)/nss-udp-st-drv/exports/* $(STAGING_DIR)/usr/include/nss-udp-st-drv/
endef

ifeq ($(CONFIG_TARGET_ipq95xx)$(CONFIG_TARGET_ipq53xx)$(CONFIG_TARGET_ipq54xx), y)
EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe

NSS_UDP_ST_DRV_MAKE_OPTS+=NSS_UDP_ST_DRV_VP=y
endif

define Build/Compile
	$(KERNEL_MAKE) $(strip $(NSS_UDP_ST_DRV_MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)/nss-udp-st-drv/" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
	cp $(PKG_BUILD_DIR)/nss-udp-st-drv/Module.symvers $(PKG_BUILD_DIR)/Module.symvers
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
