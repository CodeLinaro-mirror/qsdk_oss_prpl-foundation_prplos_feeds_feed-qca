# prplOS – U-Boot Update Script

This script updates **U-Boot, Kernel, RootFS, and mfgdata (SMD)** from **TFTP** directly inside **U-Boot**, with optional **A/B (rescue bank) support**.
Qualcomm's XBL (BL2) can also be flashed with this script but care should be taken when flashing the XBL due to risks of bricking the board.
The script performs a check of the GPT partition prior to flashing any image. This check can be disabled but care should be taken if the script reports an error with the partitioning.

---

## 1. Prerequisites

- U-Boot with: `mmc`, `tftpboot`, `setenv`, `setexpr`
- eMMC available as: `mmc 0 0`
- Block size: **512 bytes**
- Correct GPT partition layout

---

## 2. One-Time Setup (Partition Geometry)

Set these once and save:

 - Already set in the script (modify if gpt layout changes)

```bash
setenv kernel-active_block_start     0x00091422
setenv kernel-active_block_size      0x00010000
setenv kernel-inactive_block_start   0x000A1422
setenv kernel-inactive_block_size    0x00010000

setenv rootfs-active_block_start     0x000B1422
setenv rootfs-active_block_size      0x00080000
setenv rootfs-inactive_block_start   0x00131422
setenv rootfs-inactive_block_size    0x00080000

setenv mfgdata_block_start           0x001B1422
setenv mfgdata_block_size            0x00000800

# Set your real U-Boot areas:
setenv u_boot_active_block_start     <HEX>
setenv u_boot_active_block_size      <HEX>
setenv u_boot_inactive_block_start   <HEX>
setenv u_boot_inactive_block_size    <HEX>

saveenv
```

---

## 3. Per-Update Variables

Set before each update:

```bash
setenv tftppath /images/       # optional
setenv img_kernel kernel.itb   # optional
setenv img_rootfs rootfs.itb   # optional
setenv img_uboot  u-boot.itb   # optional
setenv img_xbl    xbl.elf      # optional (DANGEROUS)
setenv img_smd    smd.bin      # optional

setenv update_rescue_bank yes  # yes | no (default: no)
setenv skip_gpt_checks no      # yes | no (default: no)  (Use with caution)
```

Unset any variable to **skip** that component.

---

## 4. How to Run

```bash
tftpboot ${loadaddr} ${tftppath}update.scr
source ${loadaddr}
run update_prpl
```

Reboot when finished:

```bash
reset
```

---

## 5. Result Status

Printed at the end of execution:

- `flashed` – success
- `too_big` – image larger than partition
- `mmc_error` – eMMC error
- `tftp_failed` – TFTP/network error
- `skipped` – image not selected

---

## 6. Safety Features

- Image size checked before flashing
- Automatic block calculation
- Optional rescue bank flashing
- No erase/write from TFTP on MMC failure

---

This script is intended for **safe field upgrades on prplOS / QCA95XX devices**.
