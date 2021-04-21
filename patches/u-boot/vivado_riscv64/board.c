#include <common.h>
#include <dm.h>

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
