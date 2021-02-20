#ifndef _SDBOOT_COMMON_H
#define _SDBOOT_COMMON_H

#define BOOTROM_DTB_ADDR    0x00010080

// If the application is linked to loaded at BOOTROM_MEM_ADDR:
//   system RAM size must be >= 128MB
//   the application size must be <= (128MB - 64KB)

// Addresses must be aligned by 0x10000
#define BOOTROM_MEM_ADDR    0x80000000
#define BOOTROM_MEM_END     0x80010000
#define BOOTROM_MEM_ALT     0x87ff0000

#endif
