include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=omci
PKG_RELEASE:=1

include $(INCLUDE_DIR)/local-development.mk
ifeq ($(DUMP)$(PKG_VERSION),)
 PKG_REV:=$(shell git ls-remote $(PKG_SOURCE_URL) $(PKG_BRANCH) | cut -b -7)
 PKG_VERSION:=g$(PKG_REV)
endif

include $(INCLUDE_DIR)/package.mk

define Package/omci
  SECTION:=OPTIC_APPS
  CATEGORY:=OptiCore Packages
  SUBMENU:=Applications
  DEPENDS:=+@BUSYBOX_CONFIG_DIFF +ebtables +igmpproxy trex-drv libuci libubox util-ubus
  MENU:=
  TITLE:=omci
endef

define Package/omci/description
  OptiCtore OMCI
endef

define Package/omci/config
source "$(SOURCE)/Config.in"
endef

# CONFIG_OMCI_BM_ENABLE is defined in Config.in
ifeq ($(CONFIG_OMCI_BM_ENABLE),)
CONFIG_OMCI_BM_ENABLE=n
endif

CONFIG_USE_OPENWRT_UCI=n
CONFIG_OLT_PROP_SUPPORT_DISABLE=n
CONFIG_ERD_SUPPORT_DISABLE=n

TARGET_CFLAGS+=-DCONFIG_ARCH_QCOM -fsigned-char -I$(STAGING_DIR)/usr/include/trex -Wno-error=stringop-overflow= -Wno-error=format= -Wno-error=incompatible-pointer-types

ifneq ($(CONFIG_TARGET_ipq95xx),)
TARGET_CFLAGS+=-Wno-format-truncation -Wno-format-security -Wno-format-overflow -Wno-misleading-indentation
TARGET_CFLAGS+=-DIPQ95XX
endif

ifneq ($(CONFIG_TARGET_ipq807x),)
TARGET_CFLAGS+=-Wno-format-truncation -Wno-format-security -Wno-format-overflow -Wno-misleading-indentation
TARGET_CFLAGS+=-DIPQ807X
endif

ifneq ($(CONFIG_TARGET_ipq53xx),)
TARGET_CFLAGS+=-Wno-format-truncation -Wno-format-security -Wno-format-overflow -Wno-misleading-indentation
TARGET_CFLAGS+=-DIPQ93XX
endif

ifneq ($(CONFIG_TARGET_ipq54xx),)
TARGET_CFLAGS+=-Wno-format-truncation -Wno-format-security -Wno-format-overflow -Wno-misleading-indentation
TARGET_CFLAGS+=-DIPQ94XX
endif

ifneq ($(CONFIG_TARGET_ipq807x)$(CONFIG_TARGET_ipq)$(CONFIG_TARGET_ipq95xx)$(CONFIG_TARGET_ipq53xx)$(CONFIG_TARGET_ipq54xx),)
CONFIG_USE_OPENWRT_UCI=y
TARGET_CFLAGS+=-DUSE_MUSL_TOOL
endif

define Build/Compile
	(if [ -f $(PKG_BUILD_DIR)/src/mk_omcimain_tgz.sh ]; then \
	cd $(PKG_BUILD_DIR)/src ; \
	TOOLPREFIX="$(TARGET_CROSS)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	KERNEL_DIR="$(LINUX_DIR)" \
	OMCI_BM_ENABLE="$(CONFIG_OMCI_BM_ENABLE)" \
	OMCI_EXT_SWITCH_SUPPORT="$(CONFIG_OMCI_EXT_SWITCH_SUPPORT)" \
	USE_OPENWRT_UCI="$(CONFIG_USE_OPENWRT_UCI)" \
	OLT_PROP_SUPPORT_DISABLE="$(CONFIG_OLT_PROP_SUPPORT_DISABLE)" \
	ERD_SUPPORT_DISABLE="$(CONFIG_ERD_SUPPORT_DISABLE)" \
	CONFIG_ARCH_QCOM="y" \
	sh mk_omcimain_tgz.sh ; \
	else \
	chmod -x $(PKG_BUILD_DIR)/src/omcimain.tgz ; \
	fi)
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	(if [ "$(CONFIG_OLT_PROP_SUPPORT_DISABLE)" = "y" -o "$(CONFIG_ERD_SUPPORT_DISABLE)" = "y" ]; then \
		cd $(PKG_BUILD_DIR)/src ; \
		OLT_PROP_SUPPORT_DISABLE="$(CONFIG_OLT_PROP_SUPPORT_DISABLE)" \
		ERD_SUPPORT_DISABLE="$(CONFIG_ERD_SUPPORT_DISABLE)" \
		sh mk_omcimain_tgz.sh "baseline_src" ; \
	fi)
endef

define Package/omci/install
	@echo ""
	@echo "###############install file system $(PROFILE)#################"
	tar xvzf $(PKG_BUILD_DIR)/src/omcimain.tgz -C $(1)/
	-[ -f ./files/custom_omcienv ] && ./files/custom_omcienv.sh $(1)/etc/omci/omcienv.xml ./files/custom_omcienv
	[ ! -d $(1)/etc/init.d ] && $(INSTALL_DIR) $(1)/etc/init.d
	[ ! -d $(1)/usr/share/rpcd/acl.d ] && $(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	[ ! -d $(1)/usr/libexec/rpcd ] && $(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(CP) -f  $(PKG_BUILD_DIR)/etc/omci/script/init.d/* $(1)/etc/init.d
	$(CP) -f  $(PKG_BUILD_DIR)/etc/omci/script/rpcd/uci.json $(1)/usr/share/rpcd/acl.d
	$(CP) -f  $(PKG_BUILD_DIR)/etc/omci/script/rpcd/pots $(1)/usr/libexec/rpcd
endef

$(eval $(call BuildPackage,omci))
