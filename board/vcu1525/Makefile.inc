BOARD_PART  ?= xilinx.com:vcu1525:part0:1.3
XILINX_PART ?= xcvu9p-fsgd2104-2L-e
CFG_DEVICE  ?= SPIx4 -size 128
CFG_PART    ?= mt25qu01g-spi-x1_x2_x4
CFG_BOOT    ?= -loaddata {up 0x07000000 workspace/boot.elf}
ROOTFS      ?= NFS

ifneq ($(filter %m4,$(CONFIG)),)
MEMORY_SIZE ?= 0x1000000000
else ifneq ($(filter %m2,$(CONFIG)),)
MEMORY_SIZE ?= 0x800000000
else
MEMORY_SIZE ?= 0x400000000
endif
