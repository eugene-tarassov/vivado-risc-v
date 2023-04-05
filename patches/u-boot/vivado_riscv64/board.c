#include <common.h>
#include <dm.h>

#ifdef CONFIG_MISC_INIT_R

int misc_init_r(void) {
    /* For now nothing to do here. */
    return 0;
}

#endif

void * board_fdt_blob_setup(int * err) {
    void * fdt_blob = (void *)0x00010080;

    *err = 0;
    if (fdt_magic(fdt_blob) == FDT_MAGIC) return fdt_blob;

    *err = -EINVAL;
    return NULL;
}

int board_init(void) {
    /* For now nothing to do here. */
    return 0;
}
