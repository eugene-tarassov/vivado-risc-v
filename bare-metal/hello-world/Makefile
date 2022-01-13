CROSS_COMPILE = ../../workspace/gcc/riscv/bin/riscv64-unknown-elf-

CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump

CFLAGS = -march=rv64imfd -mabi=lp64d -fno-builtin -ffreestanding

CCFLAGS = $(CFLAGS)
CCFLAGS += -mcmodel=medany -O0 -Wall
CCFLAGS += -fno-pic -fno-common -g -I.

LFLAGS = -static -nostartfiles -T main.lds

all: boot.elf

boot.elf: head.S kprintf.c main.c
	make -C ../.. workspace/gcc/riscv
	$(CC) $(CCFLAGS) $(LFLAGS) -o $@ head.S kprintf.c main.c
	$(OBJDUMP) -h -p $@

clean:
	rm -f *.elf
