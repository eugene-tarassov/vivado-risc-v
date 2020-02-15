#ifndef _SDBOOT_COMMON_H
#define _SDBOOT_COMMON_H

#define BOOTROM_DTB_ADDR    0x00010080

// Must be aligned by 0x10000
#define BOOTROM_MEM_ADDR    0x80000000
#define BOOTROM_MEM_END     0x80010000
#define BOOTROM_MEM_ALT     0x8ff00000

#endif
