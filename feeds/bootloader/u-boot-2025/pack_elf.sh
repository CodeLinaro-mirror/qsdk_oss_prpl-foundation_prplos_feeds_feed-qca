#!/bin/sh

PKG_BUILD_DIR="$1"
CONFIG_NAME="$2"
LD_SCRIPT_NAME="$3"
ARCH="$4"
OBJCOPY="$5"
LD="$6"
BIN_DIR="$7"
SUBTARGET="$8"
VARIANT1="$9"
VARIANT2="${10}"

# Fetch TEXT_BASE and TEXT_SIZE from config file
TEXT_BASE=$(grep "^CONFIG_TEXT_BASE=" "$PKG_BUILD_DIR/configs/${CONFIG_NAME}_defconfig" | cut -d= -f2)
TEXT_SIZE=$(grep "^CONFIG_TEXT_SIZE=" "$PKG_BUILD_DIR/configs/${CONFIG_NAME}_defconfig" | cut -d= -f2)

echo "TEXT_BASE=$TEXT_BASE TEXT_SIZE=$TEXT_SIZE"

# Create linker script
cat > "$PKG_BUILD_DIR/$LD_SCRIPT_NAME" << EOF
MEMORY {
	DDR (rxw) : ORIGIN = $TEXT_BASE, LENGTH = $TEXT_SIZE
}
PHDRS {
	data PT_LOAD FLAGS(5);
}
ENTRY(_entry)
SECTIONS {
	. = $TEXT_BASE;
	_entry = . ;
	.data : { *(.data) . = ALIGN(4);} > DDR :data
	_end = .;
}
EOF

# Run objcopy and ld
$OBJCOPY -I binary -O $ARCH --change-addresses $TEXT_BASE --set-start $TEXT_BASE "$PKG_BUILD_DIR/u-boot.bin" "$PKG_BUILD_DIR/u-boot.o"
$LD "$PKG_BUILD_DIR/u-boot.o" -T "$PKG_BUILD_DIR/$LD_SCRIPT_NAME" -o "$BIN_DIR/openwrt-${VARIANT1}-${SUBTARGET}-${VARIANT2}-u-boot.elf"
