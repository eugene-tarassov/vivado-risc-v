OPTIMIZATION = -O3
INCLUDE_DIR = ./benchmark-dhrystone

# define desired dhrystone iterations
# NOTE: this needs to be a large number to make dhrystone happy enough for an accurate result
DHRY_ITERS = 3000000

TEST_SPECIFIC_FLAGS = -DDHRY_ITERS=$(DHRY_ITERS) -Dprintf=kprintf -DMSC_CLOCK

SRCS = head.S benchmark-dhrystone/dhry_1.c benchmark-dhrystone/dhry_2.c time_override.c

include ../common.mk
