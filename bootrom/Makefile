CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump

CFLAGS = -march=rv64im -mabi=lp64

CCFLAGS = $(CFLAGS)
CCFLAGS += -mcmodel=medany -Os -Wall -nostartfiles
CCFLAGS += -fno-pic -fno-common -g
CCFLAGS += -Iinclude -I.
LFLAGS = -static -nostdlib -T bootrom.lds

dts := system.dts
dtb := system.dtb

$(dtb): fixdts $(dts)
	dtc -I dts -O dtb -o $@ $(dts)

fixdts: $(dts)
	 echo -n "            " > temp && \
	 sed -n 's/.*L\(\S*\): interrupt-controller@.*/interrupt-parent = <\&L\1>;/p' $(dts) >> temp && \
	 sed -i 's/interrupt-parent = <&L.*>;/cat temp/e' $(dts) && \
	 rm temp

all: bootrom.img bootrom.elf

%.img: %.elf
	$(OBJCOPY) -O binary $< $@
	ls -l $@

%.elf: $(dtb) head.S kprintf.c bootrom.c ff.c
	$(CC) $(CCFLAGS) -DDEVICE_TREE='"$(dtb)"' $(LFLAGS) -o $@ head.S kprintf.c bootrom.c ff.c
	$(OBJDUMP) -h -p $@

clean:
	rm -f *.elf *.img *.dtb
