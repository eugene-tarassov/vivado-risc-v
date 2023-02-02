BOARD_PART  ?= xilinx.com:au200:part0:1.3
XILINX_PART ?= xcu200-fsgd2104-2-e
CFG_DEVICE  ?= SPIx4 -size 128
CFG_PART    ?= mt25qu01g-spi-x1_x2_x4
CFG_BOOT    ?= -loaddata {up 0x07000000 workspace/boot.elf}
MEMORY_SIZE ?= 0x400000000
ROOTFS      ?= NFS
