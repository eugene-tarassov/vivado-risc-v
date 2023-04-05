/* SPDX-License-Identifier: GPL-2.0+ */

#ifndef __CONFIG_H
#define __CONFIG_H

#include <linux/sizes.h>

#define CONFIG_SYS_SDRAM_BASE           0x80000000
#define CONFIG_SYS_INIT_RAM_ADDR        0x80000000
#define CONFIG_SYS_INIT_RAM_SIZE        0x00200000
#define CONFIG_STANDALONE_LOAD_ADDR     0x80200000

#define MMU_SECTION_SIZE 0x1000

#define CONFIG_SYS_BOOTM_LEN            SZ_32M
#define CONFIG_SYS_INIT_SP_ADDR         (CONFIG_SYS_SDRAM_BASE + SZ_2M)
/* Environment options */

#define BOOT_TARGET_DEVICES(func) \
        func(MMC, mmc, 0) \
        func(DHCP, dhcp, na)

#include <config_distro_bootcmd.h>

#define CONFIG_EXTRA_ENV_SETTINGS \
        "fdt_addr=0x10080\0" \
        "kernel_addr_r=0x81000000\0" \
        "fdt_addr_r=0x82fd0000\0" \
        "scriptaddr=0x82fe0000\0" \
        "pxefile_addr_r=0x82ff0000\0" \
        "bootm_low=0x83000000\0" \
        "bootm_size=0x02000000\0" \
        "ramdisk_addr_r=0x85000000\0" \
        "initrd_high=0xffffffffffffffff\0" \
        BOOTENV

#endif /* __CONFIG_H */
