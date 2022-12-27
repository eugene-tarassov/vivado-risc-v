#
# SPDX-License-Identifier: BSD-2-Clause
#

PLATFORM_RISCV_XLEN = 64

FW_TEXT_START=0x80000000
FW_DYNAMIC=n
FW_JUMP=n

# Firmware with payload configuration.
FW_PAYLOAD=y

ifeq ($(PLATFORM_RISCV_XLEN), 32)
  # This needs to be 4MB aligned for 32-bit support
  FW_PAYLOAD_OFFSET=0x400000
else
  # This needs to be 2MB aligned for 64-bit support
  FW_PAYLOAD_OFFSET=0x200000
endif
#FW_PAYLOAD_FDT_ADDR=0x82200000
FW_PAYLOAD_ALIGN=0x1000

platform-objs-y += platform.o
