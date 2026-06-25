include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-mmap-telemetry
PKG_VERSION:=1
PKG_SOURCE_PROTO:=git
PKG_BRANCH:=win.nss.1.0.r37
PKG_RELEASE:=1
PKG_LICENSE:=ISC
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/qca-mmap-telemetry
PKG_MIRROR_HASH:=1729b0bface25b904acabe1e64130a03369bfe6e9baeec79c1467db7249770bd
PKG_VERSION:=4a6fa633afa309274422bce8686f52201776e34e

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  TITLE:= UIO driver for MMAP Telemetry
  DEPENDS:= @TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx
  FILES:=$(PKG_BUILD_DIR)/mmap-telemetry.ko
  AUTOLOAD:=$(call AutoLoad,08,mmap-telemetry)
endef

define KernelPackage/$(PKG_NAME)/Description
  uio driver for MMAP telemetry
endef

define KernelPackage/$(PKG_NAME)/install
  $(INSTALL_DIR) $(1)/usr/bin
endef

define Build/Compile
  $(MAKE) $(EXTRA_CFLAGS) -C "$(LINUX_DIR)" \
    CROSS_COMPILE="$(TARGET_CROSS)" \
    ARCH="$(LINUX_KARCH)" \
    M="$(PKG_BUILD_DIR)" \
    modules
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/mmap-telemetry
	$(CP) $(PKG_BUILD_DIR)/exports/mmap_telemetry_public.h $(1)/usr/include/mmap-telemetry
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
