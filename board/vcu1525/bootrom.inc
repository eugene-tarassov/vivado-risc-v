# VCU1525 does not have SD card slot

%.elf: $(dtb) head.S kprintf.c ../board/$(BOARD)/bootrom.c
	$(CC) $(CCFLAGS) -DDEVICE_TREE='"$(dtb)"' $(LFLAGS) -o $@ head.S kprintf.c ../board/$(BOARD)/bootrom.c
