BOARD_PART  ?= NONE
XILINX_PART ?= xcux35-vsva1365-3-e
CFG_DEVICE  ?= SPIx4 -size 256
CFG_PART    ?= mt25qu02g-spi-x1_x2_x4
CFG_BOOT    ?= -loaddata {up 0x07000000 workspace/boot.elf}
ROOTFS      ?= NFS

ifneq ($(filter %m4,$(CONFIG)),)
MEMORY_SIZE ?= 0x1000000000
else ifneq ($(filter %m2,$(CONFIG)),)
MEMORY_SIZE ?= 0x800000000
else
MEMORY_SIZE ?= 0x400000000
endif
