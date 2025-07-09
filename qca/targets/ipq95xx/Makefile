include $(TOPDIR)/rules.mk

ARCH:=aarch64
BOARD:=ipq95xx
BOARDNAME:=Qualcomm Technologies, Inc. IPQ95XX
FEATURES:=squashfs fpu ramdisk nand pcie usbgadget
CPU_TYPE:=cortex-a73
CPU_SUBTYPE:=neon-vfpv4
SUBTARGETS:=generic


KERNELNAME:=Image dtbs

KERNEL_PATCHVER:=6.6

include $(INCLUDE_DIR)/target.mk
DEFAULT_PACKAGES += \
	e2fsprogs uboot-envtools kmod-leds-gpio kmod-gpio-button-hotplug kmod-button-hotplug \
	kmod-ata-core kmod-ata-ahci kmod-ata-ahci-platform kmod-usb3 \
	kmod-usb-phy-ipq807x kmod-usb-dwc3-qcom-internal \
	kmod-qca-nss-ppe kmod-qca-nss-ppe-ds kmod-qca-nss-ppe-vp \
	kmod-qca-ssdk-qca-nohnat kmod-qca-nss-dp-qca \
	kmod-qca-nss-ppe-bridge-mgr kmod-qca-nss-ppe-vlan-mgr \
	iwinfo kmod-ath12k-qca \
	kmod-leds-gpio swconfig kmod-fs-ext4 losetup \
	libudebug libustream-mbedtls libubus-lua \
	wififw_mount_script qca-wifi-scripts ath-wifi-scripts \
	kmod-bonding wpad-qca-mesh-openssl \
	kmod-qca-nss-drv kmod-qca-nss-drv-bridge-mgr kmod-qca-nss-drv-gre \
	kmod-qca-nss-drv-igs kmod-qca-nss-drv-l2tpv2 kmod-qca-nss-drv-lag-mgr kmod-qca-nss-drv-map-t \
	kmod-qca-nss-drv-match kmod-qca-nss-drv-mirror kmod-qca-nss-drv-mscs \
	kmod-qca-nss-drv-netlink kmod-qca-nss-drv-ovpn-link kmod-qca-nss-drv-ovpn-mgr kmod-qca-nss-drv-pppoe \
	kmod-qca-nss-drv-qdisc kmod-qca-nss-drv-tun6rd kmod-qca-nss-drv-tunipip6 \
	kmod-qca-nss-drv-vxlanmgr kmod-qca-nss-drv-wifi-meshmg \
	kmod-qca-nss-ppe-bridge-mgr \
	kmod-qca-nss-ppe-pppoe-mgr \
	kmod-qca-nss-ppe-lag-mgr \
	kmod-qca-nss-ppe-tunipip6 qca-nss-ppe-tun \
	kmod-qca-nss-ppe-gretap \
	kmod-qca-nss-ppe-vxlanmgr \
	kmod-qca-nss-ppe-mapt \
	kmod-qca-nss-ppe-rule qca-nss-ppe-netlink \
	kmod-qca-nss-ppe-qdisc \
	kmod-qca-nss-drv-pptp kmod-pptp kmod-emesh-sp \
	kmod-qca-nss-ppe-mirror-test \
	kmod-qca-nss-macsec kmod-qca-nss-crypto qca-wifi-hk-fw-hw1-10.4-asic kmod-qca-nss-ecm-wifi-plugin \
	kmod-qca-nss-sfe kmod-crypto-authenc kmod-qca-nss-ecm-premium  kmod-qca-ovsmgr \
	-kmod-qca-nss-cfi-cryptoapi  -kmod-qca-nss-gmac \
	-kmod-qca-nss-cfi-ocf kmod-qca-nss-ppe-mirror-test \
	kmod-nss-udp-st-drv kmod-qca-nss-dscpstats kmod-qca-nss-nsm \
	kmod-qca8084 kmod-qca81xx kmod-aqr-phy kmod-qca8xxx-phc kmod-qca8k \
	kmod-qca-nss-ppe-dsa-mgr kmod-qca-nss-flowmgr kmod-qca-nss-ppe-netlink kmod-qca-nss-fls kmod-qca-nss-netfn-tcpst \
	ftm myftm diag cnssdiag

export KERNEL_DETAILS_FILE_CUSTOM=$(PLATFORM_DIR)/kernel-$(KERNEL_PATCHVER)
GENERIC_LINUX_CONFIG = $(PLATFORM_DIR)/generic/config-$(KERNEL_PATCHVER)-platform
export GENERIC_BACKPORT_DIR_CUSTOM := empty
export GENERIC_PATCH_DIR_CUSTOM := empty
export GENERIC_HACK_DIR_CUSTOM := empty
export GENERIC_FILES_DIR_CUSTOM := $(FILES_DIR)

define Kernel/Prepare
	$(LINUX_CAT) $(DL_DIR)/$(LINUX_SOURCE) | $(TAR) -C $(KERNEL_BUILD_DIR) $(TAR_OPTIONS)

	$(if $(QUILT),rm -rf $(LINUX_DIR)/patches; mkdir -p $(LINUX_DIR)/patches)
	$(if $(FILES_DIR),$(CP) $(FILES_DIR)/* $(LINUX_DIR)/)
	find $(LINUX_DIR)/ -name \*.rej -or -name \*.orig | $(XARGS) rm -f
	$(call PatchDir,$(LINUX_DIR),$(PATCH_DIR),platform/)

	$(if $(QUILT),touch $(LINUX_DIR)/.quilt_used)
endef

define Kernel/Configure
	$(call Kernel/Configure/Default)
	echo '# CONFIG_INITRAMFS_PRESERVE_MTIME is not set' >> $(LINUX_DIR)/.config
endef

$(eval $(call BuildTarget))
