OPTIMIZATION = -O3
INCLUDE_DIR = ./coremark

# define desired coremark iterations
ITERATIONS = 5000

TEST_SPECIFIC_FLAGS = '-DITERATIONS=$(ITERATIONS)'

SRCS = head.S coremark/core_list_join.c coremark/core_main.c coremark/core_matrix.c coremark/core_state.c coremark/core_util.c core_portme.c

include ../common.mk
