#include <stdint.h>
#include <stdlib.h>
#include <diskio.h>
#include <ff.h>

#include "common.h"
#include "kprintf.h"

/* Card type flags (card_type) */
#define CT_MMC          0x01            /* MMC ver 3 */
#define CT_SD1          0x02            /* SD ver 1 */
#define CT_SD2          0x04            /* SD ver 2 */
#define CT_SDC          (CT_SD1|CT_SD2) /* SD */
#define CT_BLOCK        0x08            /* Block addressing */

#define CMD0    (0)             /* GO_IDLE_STATE */
#define CMD1    (1)             /* SEND_OP_COND */
#define CMD2    (2)             /* SEND_CID */
#define CMD3    (3)             /* RELATIVE_ADDR */
#define CMD4    (4)
#define CMD5    (5)             /* SLEEP_WAKE (SDC) */
#define CMD6    (6)             /* SWITCH_FUNC */
#define CMD7    (7)             /* SELECT */
#define CMD8    (8)             /* SEND_IF_COND */
#define CMD9    (9)             /* SEND_CSD */
#define CMD10   (10)            /* SEND_CID */
#define CMD11   (11)
#define CMD12   (12)            /* STOP_TRANSMISSION */
#define CMD13   (13)
#define CMD15   (15)
#define CMD16   (16)            /* SET_BLOCKLEN */
#define CMD17   (17)            /* READ_SINGLE_BLOCK */
#define CMD18   (18)            /* READ_MULTIPLE_BLOCK */
#define CMD19   (19)
#define CMD20   (20)
#define CMD23   (23)
#define CMD24   (24)
#define CMD25   (25)
#define CMD27   (27)
#define CMD28   (28)
#define CMD29   (29)
#define CMD30   (30)
#define CMD32   (32)
#define CMD33   (33)
#define CMD38   (38)
#define CMD42   (42)
#define CMD55   (55)            /* APP_CMD */
#define CMD56   (56)
#define ACMD6   (0x80+6)        /* define the data bus width */
#define ACMD41  (0x80+41)       /* SEND_OP_COND (ACMD) */

// Capability bits
#define SDC_CAPABILITY_SD_4BIT  0x0001
#define SDC_CAPABILITY_SD_RESET 0x0002

// Control bits
#define SDC_CONTROL_SD_4BIT     0x0001
#define SDC_CONTROL_SD_RESET    0x0002

// Card detect bits
#define SDC_CARD_INSERT_INT_EN  0x0001
#define SDC_CARD_INSERT_INT_REQ 0x0002
#define SDC_CARD_REMOVE_INT_EN  0x0004
#define SDC_CARD_REMOVE_INT_REQ 0x0008

// Command status bits
#define SDC_CMD_INT_STATUS_CC   0x0001  // Command complete
#define SDC_CMD_INT_STATUS_EI   0x0002  // Any error
#define SDC_CMD_INT_STATUS_CTE  0x0004  // Timeout
#define SDC_CMD_INT_STATUS_CCRC 0x0008  // CRC error
#define SDC_CMD_INT_STATUS_CIE  0x0010  // Command code check error

// Data status bits
#define SDC_DAT_INT_STATUS_TRS  0x0001  // Transfer complete
#define SDC_DAT_INT_STATUS_ERR  0x0002  // Any error
#define SDC_DAT_INT_STATUS_CTE  0x0004  // Timeout 
#define SDC_DAT_INT_STATUS_CRC  0x0008  // CRC error
#define SDC_DAT_INT_STATUS_CFE  0x0010  // Data FIFO underrun or overrun

#define ERR_EOF             30
#define ERR_NOT_ELF         31
#define ERR_ELF_BITS        32
#define ERR_ELF_ENDIANNESS  33

struct sdc_regs {
    volatile uint32_t argument;
    volatile uint32_t command;
    volatile uint32_t response1;
    volatile uint32_t response2;
    volatile uint32_t response3;
    volatile uint32_t response4;
    volatile uint32_t data_timeout;
    volatile uint32_t control;
    volatile uint32_t cmd_timeout;
    volatile uint32_t clock_divider;
    volatile uint32_t software_reset;
    volatile uint32_t power_control;
    volatile uint32_t capability;
    volatile uint32_t cmd_int_status;
    volatile uint32_t cmd_int_enable;
    volatile uint32_t dat_int_status;
    volatile uint32_t dat_int_enable;
    volatile uint32_t block_size;
    volatile uint32_t block_count;
    volatile uint32_t card_detect;
    volatile uint32_t res_50;
    volatile uint32_t res_54;
    volatile uint32_t res_58;
    volatile uint32_t res_5c;
    volatile uint32_t dma_addres;
};

#define MAX_BLOCK_CNT 0x1000

/* Note: .data section not supported in BootROM */

static struct sdc_regs * const regs __attribute__((section(".rodata"))) = (struct sdc_regs *)0x60000000;

static int errno __attribute__((section(".bss")));
static DSTATUS drv_status __attribute__((section(".bss")));
static BYTE card_type __attribute__((section(".bss")));
static uint32_t response[4] __attribute__((section(".bss")));
static FATFS fatfs __attribute__((section(".bss")));
static int alt_mem __attribute__((section(".bss")));

extern unsigned char _ram[];
extern unsigned char _ram_end[];

extern unsigned char _ftext[];
extern unsigned char _etext[];
extern unsigned char _fbss[];
extern unsigned char _ebss[];

static void usleep(unsigned us) {
    uintptr_t cycles0;
    uintptr_t cycles1;
    asm volatile ("csrr %0, 0xB00" : "=r" (cycles0));
    for (;;) {
        asm volatile ("csrr %0, 0xB00" : "=r" (cycles1));
        if (cycles1 - cycles0 >= us * 100) break;
    }
}

static int sdc_finish(unsigned cmd) {
    while (1) {
        unsigned status = regs->cmd_int_status;
        if (status) {
#if 0
            dprintf("cmd %x (%d) %c%c, status %x\n",
                cmd, cmd,
                regs->command & (1 << 5) ? 'R' : ' ',
                regs->command & (1 << 6) ? 'W' : ' ',
                status);
#endif
            // clear interrupts
            regs->cmd_int_status = 0;
            while (regs->software_reset != 0) {}
            if (status == SDC_CMD_INT_STATUS_CC) {
                // get response
                response[0] = regs->response1;
                response[1] = regs->response2;
                response[2] = regs->response3;
                response[3] = regs->response4;
                return 0;
            }
            break;
        }
    }
    return -1;
}

static int sdc_data_finish(void) {
    int status;

    while ((status = regs->dat_int_status) == 0) {}
    regs->dat_int_status = 0;
    while (regs->software_reset != 0) {}

    if (status == SDC_DAT_INT_STATUS_TRS) return 0;
    return -1;
}

static int send_data_cmd(unsigned cmd, unsigned arg, void * buf, unsigned blocks) {
    unsigned command = (cmd & 0x3f) << 8;
    switch (cmd) {
    case CMD0:
    case CMD4:
    case CMD15:
        // No responce
        break;
    case CMD11:
    case CMD13:
    case CMD16:
    case CMD17:
    case CMD18:
    case CMD19:
    case CMD23:
    case CMD24:
    case CMD25:
    case CMD27:
    case CMD30:
    case CMD32:
    case CMD33:
    case CMD42:
    case CMD55:
    case CMD56:
    case ACMD6:
        // R1
        command |= 1; // 48 bits
        command |= 1 << 3; // resp CRC
        command |= 1 << 4; // resp OPCODE
        break;
    case CMD7:
    case CMD12:
    case CMD20:
    case CMD28:
    case CMD29:
    case CMD38:
        // R1b
        command |= 1; // 48 bits
        command |= 1 << 3; // resp CRC
        command |= 1 << 4; // resp OPCODE
        command |= 1 << 2; // R1b
        break;
    case CMD2:
    case CMD9:
    case CMD10:
        // R2
        command |= 2; // 136 bits
        command |= 1 << 3; // resp CRC
        break;
    case ACMD41:
        // R3
        command |= 1; // 48 bits
        break;
    case CMD3:
        // R6
        command |= 1; // 48 bits
        command |= 1 << 3; // resp CRC
        command |= 1 << 4; // resp OPCODE
        break;
    case CMD8:
        // R7
        command |= 1; // 48 bits
        command |= 1 << 3; // resp CRC
        command |= 1 << 4; // resp OPCODE
        break;
    }

    if (blocks) {
        command |= 1 << 5;
        if ((intptr_t)buf & 3) return -1;
        regs->dma_addres = (uint32_t)(intptr_t)buf;
        regs->block_size = 511;
        regs->block_count = blocks - 1;
        regs->data_timeout = 0xFFFFF;
    }

    regs->command = command;
    regs->cmd_timeout = 0xFFFF;
    regs->argument = arg;

    if (sdc_finish(cmd) < 0) return -1;
    if (blocks) return sdc_data_finish();

    return 0;
}

static int send_cmd(unsigned cmd, unsigned arg) {
    return send_data_cmd(cmd, arg, NULL, 0);
}

WCHAR ff_convert(WCHAR ch, UINT unicode) {
    return ch;
}

WCHAR ff_wtoupper(WCHAR ch) {
    if (ch >= 'a' && ch <= 'z') return ch - 'a' + 'A';
    return ch;
}

DSTATUS disk_status(BYTE drv) {
    return drv_status;
}

DRESULT disk_read(BYTE drv, BYTE * buf, DWORD sector, BYTE count) {
    DSTATUS s;

    if (!count) return RES_PARERR;
    s = disk_status(drv);
    if (s & STA_NOINIT) return RES_NOTRDY;

    /* Convert LBA to byte address if needed */
    if (!(card_type & CT_BLOCK)) sector *= 512;
    while (count > 0) {
        BYTE bcnt = count > MAX_BLOCK_CNT ? MAX_BLOCK_CNT : count;
        unsigned bytes = bcnt * 512;
        if (send_data_cmd(bcnt == 1 ? CMD17 : CMD18, sector, buf, bcnt) == 0 &&
                (bcnt == 1 || send_cmd(CMD12, 0) == 0)) {
            if (card_type & CT_BLOCK) {
                sector += bcnt;
            }
            else {
                sector += bytes;
            }
            buf += bytes;
            count -= bcnt;
        }
        else {
            kprintf("SD read error, sector: %d\n", (int)sector);
            break;
        }
    }

    return count ? RES_ERROR : RES_OK;
}

DSTATUS disk_initialize(BYTE drv) {
    unsigned rca;

    /* Reset controller */
    regs->software_reset = 1;
    while ((regs->software_reset & 1) == 0) {}
    regs->clock_divider = 0x7c;
    regs->software_reset = 0;
    while (regs->software_reset) {}
    usleep(5000);

    card_type = 0;
    drv_status = STA_NOINIT;

    /* Check if card is in the socket */
    drv_status = disk_status(drv);
    if (drv_status & STA_NODISK) {
        kprintf("No SD card present.\n");
        return drv_status;
    }

    if (regs->capability & SDC_CAPABILITY_SD_RESET) {
        /* Power cycle SD card */
        regs->control |= SDC_CONTROL_SD_RESET;
        usleep(1000000);
        regs->control &= ~SDC_CONTROL_SD_RESET;
        usleep(100000);
    }

    /* Enter Idle state */
    send_cmd(CMD0, 0);

    if (send_cmd(CMD8, 0x1AA) == 0) {
        card_type = CT_SD1;
        if ((response[0] & 0xfff) == 0x1AA) card_type = CT_SD2;
    }
    else {
        kprintf("CMD8 failed.\n");
        return drv_status;
    }

    /* Wait for leaving idle state (ACMD41 with HCS bit) */
    while (1) {
        /* ACMD41, Set Operating Conditions */
        send_cmd(CMD55, 0);
        /* Host High Capacity & 3.3V */
        if (send_cmd(ACMD41, 0x40300000) == 0) {
            if (response[0] & (1 << 31)) {
                if (response[0] & (1 << 30)) card_type |= CT_BLOCK;
                break;
            }
        }
        else {
            kprintf("ACMD41 failed.\n");
            return STA_NOINIT;
        }
    }

    /* Get CID */
    if (send_cmd(CMD2, 0) != 0) {
        kprintf("Cannot get CID\n");
        return STA_NOINIT;
    }

    /* Get RCA */
    rca = 0x1234;
    send_cmd(CMD3, rca << 16);
    rca = response[0] >> 16;

    /* Select card */
    if (send_cmd(CMD7, rca << 16) != 0) {
        kprintf("Cannot select the card\n");
        return STA_NOINIT;
    }

    /* Set R/W block length to 512 */
    if (send_cmd(CMD16, 512) != 0) {
        kprintf("Cannot set block length\n");
        return STA_NOINIT;
    }

    regs->control = 0;
    if (send_cmd(CMD55, rca << 16) || send_cmd(ACMD6, 0)) {
        kprintf("Cannot set bus bits\n");
        return STA_NOINIT;
    }

    regs->clock_divider = 3;
    usleep(10000);

    drv_status &= ~STA_NOINIT;

    return drv_status;
}

static uintptr_t read_num(FIL * fd, unsigned size) {
    uint8_t buf[0x10];
    uintptr_t v = 0;
    unsigned n = 0;
    UINT rd;
    errno = f_read(fd, buf, size, &rd);
    if (errno) return 0;
    if (rd < size) {
        errno = ERR_EOF;
        return 0;
    }
    for (n = 0; n < size; n++) {
        v |= (uintptr_t)(buf[n]) << (n * 8);
    }
    return v;
}

#define read_uint16() (uint16_t)read_num(&fd, 2)
#define read_uint32() (uint32_t)read_num(&fd, 4)
#define read_addr() (uintptr_t)read_num(&fd, __riscv_xlen >> 3)

#define PT_LOAD 1

static int download(void) {
    const char * fnm = "BOOT.ELF";
    uint8_t buf[0x10];
    uintptr_t entry_addr = 0;
    uint64_t phoff = 0;
    uint16_t phentsize = 0;
    uint16_t phnum = 0;
    unsigned i = 0;
    FIL fd;

    errno = f_open(&fd, fnm, FA_READ);
    if (errno) return -1;

    UINT rd = 0;
    errno = f_read(&fd, buf, 6, &rd);
    if (errno) return -1;
    if (rd < 6) {
        errno = ERR_EOF;
        return -1;
    }
    if (buf[0] != 0x7f || buf[1] != 'E' || buf[2] != 'L' || buf[3] != 'F') {
        errno = ERR_NOT_ELF;
        return -1;
    }
    if (buf[4] != (__riscv_xlen == 32 ? 1 : 2)) {
        errno = ERR_ELF_BITS;
        return -1;
    }
    if (buf[5] != 1) {
        errno = ERR_ELF_ENDIANNESS;
        return -1;
    }
    errno = f_lseek(&fd, 24);
    if (errno) return -1;
    entry_addr = read_addr();
    if (errno) return -1;
    phoff = read_addr();
    if (errno) return -1;
    errno = f_lseek(&fd, f_tell(&fd) + 8 + 6);
    if (errno) return -1;
    phentsize = read_uint16();
    if (errno) return -1;
    phnum = read_uint16();
    if (errno) return -1;
    for (i = 0; i < phnum; i++) {
        uint32_t p_type = 0;
        uint64_t p_offset = 0;
        uint64_t p_vaddr = 0;
        uint64_t p_filesz = 0;
        uint64_t p_memsz = 0;
        uintptr_t addr = 0;
        size_t pos = 0;
        errno = f_lseek(&fd, phoff + i * phentsize);
        if (errno) return -1;
        p_type = read_uint32();
        if (errno) return -1;
        if (p_type != PT_LOAD) continue;
        errno = f_lseek(&fd, f_tell(&fd) + 4);
        if (errno) return -1;
        p_offset = read_addr();
        if (errno) return -1;
        p_vaddr = read_addr();
        if (errno) return -1;
        read_addr(); /* p_paddr */
        if (errno) return -1;
        p_filesz = read_addr();
        if (errno) return -1;
        p_memsz = read_addr();
        if (errno) return -1;
        errno = f_lseek(&fd, p_offset);
        if (errno) return -1;
        addr = p_vaddr;
        while (pos < p_filesz && pos < p_memsz) {
            uint8_t * mem = (void *)addr;
            size_t size = 0x10000;
            if (size > p_filesz - pos) size = (size_t)(p_filesz - pos);
            if (size > p_memsz - pos) size = (size_t)(p_memsz - pos);
            if (addr + size >= BOOTROM_MEM_ADDR && addr < BOOTROM_MEM_END) {
                mem = (uint8_t *)(addr - BOOTROM_MEM_ADDR + BOOTROM_MEM_ALT);
                if (addr + size >= BOOTROM_MEM_END) size = BOOTROM_MEM_END - addr;
                alt_mem = 1;
            }
            errno = f_read(&fd, mem, size, &rd);
            if (errno) return -1;
            if (rd == 0) {
                errno = ERR_EOF;
                return -1;
            }
            if (size >(size_t)rd) size = (size_t)rd;
            addr += size;
            pos += size;
        }
        while (pos < p_memsz) {
            uint8_t * mem = (void *)addr;
            size_t size = 0x10000;
            if (size > p_memsz - pos) size = (size_t)p_memsz - pos;
            if (addr + size >= BOOTROM_MEM_ADDR && addr < BOOTROM_MEM_END) {
                mem = (uint8_t *)(addr - BOOTROM_MEM_ADDR + BOOTROM_MEM_ALT);
                if (addr + size >= BOOTROM_MEM_END) size = BOOTROM_MEM_END - addr;
                alt_mem = 1;
            }
            size_t s = size;
            while (s) {
                *mem++ = 0;
                s--;
            }
            addr += size;
            pos += size;
        }
    }
    errno = f_close(&fd);
    if (errno) return -1;

    asm volatile ("li  a0, 0"); // Hart No
    asm volatile ("li  a1, %0" :: "n" (BOOTROM_DTB_ADDR)); // Device Tree
    if (alt_mem) {
        asm volatile ("lui  t0, %0" :: "n" (BOOTROM_MEM_ADDR >> 16));
        asm volatile ("lui  t1, %0" :: "n" (BOOTROM_MEM_END >> 16));
        asm volatile ("lui  t2, %0" :: "n" (BOOTROM_MEM_ALT >> 16));
        asm volatile ("slli t0, t0, 4");
        asm volatile ("slli t1, t1, 4");
        asm volatile ("slli t2, t2, 4");
#if __riscv_xlen == 32
        asm volatile ("lw   a5, %0" :: "m" (entry_addr));
        asm volatile ("boot_rom_memcpy:");
        asm volatile ("lw   t3, 0(t2)");
        asm volatile ("sw   t3, 0(t0)");
        asm volatile ("lw   t3, 4(t2)");
        asm volatile ("sw   t3, 4(t0)");
#else
        asm volatile ("ld   a5, %0" :: "m" (entry_addr));
        asm volatile ("boot_rom_memcpy:");
        asm volatile ("ld   t3, 0(t2)");
        asm volatile ("sd   t3, 0(t0)");
#endif
        asm volatile ("addi t0, t0, 8");
        asm volatile ("addi t2, t2, 8");
        asm volatile ("bne  t0, t1, boot_rom_memcpy");
        asm volatile ("jr   a5");
    }
    asm volatile ("jr %0" :: "r" (entry_addr));

    return 0;
}

static const char * errno_to_str(void) {
    switch (errno) {
    case FR_OK              : return "No error";
    case FR_DISK_ERR        : return "Disk I/O error";
    case FR_INT_ERR         : return "Assertion failed";
    case FR_NOT_READY       : return "Disk not ready";
    case FR_NO_FILE         : return "Could not find the file";
    case FR_NO_PATH         : return "Could not find the path";
    case FR_INVALID_NAME    : return "The path name format is invalid";
    case FR_DENIED          : return "Acces denied due to prohibited access or directory full";
    case FR_EXIST           : return "Acces denied due to prohibited access";
    case FR_INVALID_OBJECT  : return "The file/directory object is invalid";
    case FR_WRITE_PROTECTED : return "The physical drive is write protected";
    case FR_INVALID_DRIVE   : return "The logical drive number is invalid";
    case FR_NOT_ENABLED     : return "The volume has no work area";
    case FR_NO_FILESYSTEM   : return "There is no valid FAT volume on the physical drive";
    case FR_MKFS_ABORTED    : return "The f_mkfs() aborted due to any parameter error";
    case FR_TIMEOUT         : return "Could not get a grant to access the volume within defined period";
    case FR_LOCKED          : return "The operation is rejected according to the file shareing policy";
    case FR_NOT_ENOUGH_CORE : return "LFN working buffer could not be allocated";
    case FR_TOO_MANY_OPEN_FILES: return "Too many open files";
    case ERR_EOF            : return "Unexpected EOF";
    case ERR_NOT_ELF        : return "Not an ELF file";
    case ERR_ELF_BITS       : return "Wrong ELF word size";
    case ERR_ELF_ENDIANNESS : return "Wrong ELF endianness";
    }
    return "Unknown error code";
}

int main(void) {
    uint64_t * bss = (uint64_t *)_fbss;
    while (bss < (uint64_t *)_ebss) *bss++ = 0;

    for (;;) {
        FATFS * fs = NULL;
        TCHAR fnm[1];
        const TCHAR * p = fnm;
        fnm[0] = 0;
        kputs("");
        kprintf("RISC-V %d, Boot ROM V3.0\n", __riscv_xlen);
        drv_status = STA_NOINIT;
        errno = f_mount(0, &fatfs) != FR_OK || chk_mounted(&p, &fs, 0);
        if (errno) {
            kprintf("Cannot mount SD: %s\n", errno_to_str());
        }
        else if (download() != 0) {
            kprintf("Cannot read BOOT.ELF: %s\n", errno_to_str());
        }
        usleep(1000000);
    }
    return 0;
}
