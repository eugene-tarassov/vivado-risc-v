#include <common.h>
#include <dm.h>

#if defined(CONFIG_OF_BOARD)
void * board_fdt_blob_setup(void) {
    static void * dtb = (void *)0x10080;

    if (fdt_magic(dtb) != FDT_MAGIC) {
        printf("Corrupted DTB\n");
        return NULL;
    }

    return dtb;
}
#endif

#ifdef CONFIG_MISC_INIT_R

int misc_init_r(void) {
    /* For now nothing to do here. */
    return 0;
}

#endif

int board_init(void) {
    /* For now nothing to do here. */
    return 0;
}
