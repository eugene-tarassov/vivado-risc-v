#ifndef _SDBOOT_COMMON_H
#define _SDBOOT_COMMON_H

#define BOOTROM_DTB_ADDR    0x00010080

// Addresses must be aligned by 0x100
#define BOOTROM_MEM_ADDR    0x80000000
#define BOOTROM_MEM_END     0x80002000

#ifndef BOOTROM_MEM_ALT
// If the application is linked to be loaded at BOOTROM_MEM_ADDR:
//   BOOTROM_MEM_ALT is used as temporary storage
//   system RAM size must be >= 128MB
//   the application size must be <= (128MB - 8KB)
#define BOOTROM_MEM_ALT     0x87ffe000
#endif

#endif
