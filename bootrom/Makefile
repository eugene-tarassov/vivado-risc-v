CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump

CFLAGS = -march=rv64im -mabi=lp64

CCFLAGS = $(CFLAGS)
CCFLAGS += -mcmodel=medany -Os -ffunction-sections -Wall
CCFLAGS += -fno-pic -fno-common -g -I.

LFLAGS = -static -nostartfiles -T bootrom.lds -Wl,--gc-sections

dts := system.dts
dtb := system.dtb

$(dtb): $(dts)
	dtc -I dts -O dtb -o $@ $<

all: bootrom.img bootrom.elf

%.img: %.elf
	$(OBJDUMP) -h -p $<
	$(OBJCOPY) -O binary $< $@
	ls -l $@

ifneq (,$(wildcard ../board/$(BOARD)/bootrom.inc))

include ../board/$(BOARD)/bootrom.inc

else

%.elf: $(dtb) head.S kprintf.c bootrom.c ff.c ffunicode.c
	$(CC) $(CCFLAGS) -DDEVICE_TREE='"$(dtb)"' $(LFLAGS) -o $@ head.S kprintf.c bootrom.c ff.c ffunicode.c

endif

clean:
	rm -f *.elf *.img *.dtb
