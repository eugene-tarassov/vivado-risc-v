apt-install:
	sudo apt update
	sudo apt upgrade
	sudo apt -y install default-jdk device-tree-compiler python \
	 libmpc-dev gcc gcc-riscv64-linux-gnu gcc-8-riscv64-linux-gnu flex bison

update-submodules:
	git submodule update --init --force --recursive

clean-submodules:
	git submodule foreach --recursive git clean -xfdq

# --- download tools, initrd and rootfs ---

workspace/gcc/riscv:
	mkdir -p workspace/gcc
	cd workspace/gcc &&\
	  curl --netrc --location --header 'Accept: application/octet-stream' \
	  https://api.github.com/repos/eugene-tarassov/vivado-risc-v/releases/assets/18060315 |\
	  tar xz

debian-riscv64/initrd:
	mkdir -p debian-riscv64
	curl --netrc --location --header 'Accept: application/octet-stream' \
	  https://api.github.com/repos/eugene-tarassov/vivado-risc-v/releases/assets/18763506 \
	  -o $@

debian-riscv64/rootfs.tar.gz:
	mkdir -p debian-riscv64
	curl --netrc --location --header 'Accept: application/octet-stream' \
	  https://api.github.com/repos/eugene-tarassov/vivado-risc-v/releases/assets/18763518 \
	  -o $@


# --- build Linux kernel ---

linux: linux-stable/arch/riscv/boot/Image

CROSS_COMPILE_LINUX = /usr/bin/riscv64-linux-gnu-

linux-patch: patches/linux.patch patches/fpga-axi-sdc.c patches/fpga-axi-eth.c patches/linux.config
	cd linux-stable && git reset --hard && patch -p1 <../patches/linux.patch
	cp patches/fpga-axi-eth.c  linux-stable/drivers/net/ethernet
	cp patches/fpga-axi-sdc.c  linux-stable/drivers/mmc/host
	cp patches/linux.config linux-stable/.config

linux-stable/arch/riscv/boot/Image: linux-patch
	make -C linux-stable ARCH=riscv CROSS_COMPILE=$(CROSS_COMPILE_LINUX) oldconfig
	make -C linux-stable ARCH=riscv CROSS_COMPILE=$(CROSS_COMPILE_LINUX) all


# --- build U-Boot ---

u-boot: u-boot/u-boot

U_BOOT_SRC = $(wildcard patches/u-boot/*/*) \
  patches/u-boot/vivado_riscv64_defconfig \
  patches/u-boot/vivado_riscv64.h \
  patches/u-boot.patch

u-boot-patch: $(U_BOOT_SRC)
	cd u-boot && git reset --hard && patch -p1 <../patches/u-boot.patch
	cp -r patches/u-boot/vivado_riscv64 u-boot/board/xilinx
	cp patches/u-boot/vivado_riscv64_defconfig u-boot/configs
	cp patches/u-boot/vivado_riscv64.h u-boot/include/configs

u-boot/u-boot: u-boot-patch $(U_BOOT_SRC)
	make -C u-boot CROSS_COMPILE=$(CROSS_COMPILE_LINUX) vivado_riscv64_config
	make -C u-boot \
	  CC=$(CROSS_COMPILE_LINUX)gcc-8 \
	  CROSS_COMPILE=$(CROSS_COMPILE_LINUX) \
	  KCFLAGS='-O1 -gno-column-info' \
	  all


# --- build RISC-V Berkeley Boot Loader ---

bbl: riscv-pk/build/bbl

riscv-pk/build:
	cd riscv-pk &&\
	mkdir build &&\
	cd build &&\
	  ../configure \
	  --host=riscv64-linux-gnu \
	  --with-arch=rv64imafdc \
	  --with-abi=lp64d \
	  --with-payload=../../u-boot/u-boot \
	  --with-mem-start=0x80000000

riscv-pk-patch: riscv-pk/build patches/riscv-pk-uart.c
	cp patches/riscv-pk-uart.c riscv-pk/machine/uart.c

riscv-pk/build/bbl: riscv-pk-patch u-boot/u-boot
	make -C riscv-pk/build mabi='-mabi=lp64d -O0 -g' bbl


# --- generate HDL ---

CONFIG_SCALA = $(subst rocket,Rocket,$(CONFIG))

ifeq ($(BOARD),vc707)
  ROCKET_FREQ ?= 100
  BOARD_PART  ?= xilinx.com:vc707:part0:1.4
  XILINX_PART ?= xc7vx485tffg1761-2
  MEMORY_SIZE ?= 0x40000000
  ETHER_MAC   ?= 00 0a 35 00 00 00
endif

ifeq ($(BOARD),nexys-video)
  ROCKET_FREQ ?= 50
  BOARD_PART  ?= digilentinc.com:nexys_video:part0:1.1
  XILINX_PART ?= xc7a200tsbg484-1
  MEMORY_SIZE ?= 0x20000000
  ETHER_MAC   ?= 00 0a 35 00 00 01
endif

ifeq ($(findstring rocket64,$(CONFIG)),)
  CROSS_COMPILE_NO_OS_TOOLS = $(realpath workspace/gcc/riscv/bin)/riscv32-unknown-elf-
  CROSS_COMPILE_NO_OS_FLAGS = -march=rv32im -mabi=ilp32
else
  CROSS_COMPILE_NO_OS_TOOLS = $(realpath workspace/gcc/riscv/bin)/riscv64-unknown-elf-
  CROSS_COMPILE_NO_OS_FLAGS = -march=rv64im -mabi=lp64
endif

workspace/$(CONFIG)/system.v: rocket.scala
	cd rocket-chip && git reset --hard && patch -p1 <../patches/rocket-chip.patch
	cp rocket-chip/bootrom/bootrom.img bootrom
	cp rocket.scala rocket-chip/src/main/scala
	env ROCKETCHIP=`pwd`/rocket-chip \
	  make -C rocket-chip/vsim RISCV=/tmp JVM_MEMORY=4G MODEL=RocketSystem CONFIG=$(CONFIG_SCALA) clean verilog
	mkdir -p workspace/$(CONFIG)
	cp rocket-chip/vsim/generated-src/freechips.rocketchip.system.$(CONFIG_SCALA).dts workspace/$(CONFIG)/system.dts
	cp rocket-chip/vsim/generated-src/freechips.rocketchip.system.$(CONFIG_SCALA).behav_srams.v workspace/$(CONFIG)/srams.v
	cp rocket-chip/vsim/generated-src/freechips.rocketchip.system.$(CONFIG_SCALA).v $@

workspace/$(CONFIG)/system-$(BOARD).v: workspace/gcc/riscv rocket.scala workspace/$(CONFIG)/system.v
	cat workspace/$(CONFIG)/system.dts bootrom/bootrom.dts >bootrom/system.dts
	sed -i "s#reg = <0x80000000 0x40000000>#reg = <0x80000000 $(MEMORY_SIZE)>#g" bootrom/system.dts
	sed -i "s#clock-frequency = <100000000>#clock-frequency = <$(ROCKET_FREQ)000000>#g" bootrom/system.dts
	sed -i "s#timebase-frequency = <1000000>#timebase-frequency = <$(ROCKET_FREQ)0000>#g" bootrom/system.dts
	sed -i "s#local-mac-address = \[.*\]#local-mac-address = [$(ETHER_MAC)]#g" bootrom/system.dts
	make -C bootrom CROSS_COMPILE="$(CROSS_COMPILE_NO_OS_TOOLS)" CFLAGS="$(CROSS_COMPILE_NO_OS_FLAGS)" clean bootrom.img
	cp bootrom/system.dts workspace/$(CONFIG)/system-$(BOARD).dts
	cd rocket-chip && git reset --hard && patch -p1 <../patches/rocket-chip.patch
	cp rocket.scala rocket-chip/src/main/scala
	env ROCKETCHIP=`pwd`/rocket-chip \
	  make -C rocket-chip/vsim RISCV=/tmp JVM_MEMORY=4G MODEL=RocketSystem CONFIG=$(CONFIG_SCALA) clean verilog
	cp rocket-chip/vsim/generated-src/freechips.rocketchip.system.$(CONFIG_SCALA).v $@

workspace/$(CONFIG)/rocket.vhdl: workspace/$(CONFIG)/system.v
	mkdir -p vhdl-wrapper/bin
	javac -g -nowarn \
	  -sourcepath vhdl-wrapper/src -d vhdl-wrapper/bin \
	  -classpath vhdl-wrapper/antlr-4.7.2-complete.jar \
	  vhdl-wrapper/src/net/largest/riscv/vhdl/Main.java
	java -classpath \
	  vhdl-wrapper/src:vhdl-wrapper/bin:vhdl-wrapper/antlr-4.7.2-complete.jar \
	  net.largest.riscv.vhdl.Main \
	  workspace/$(CONFIG)/system.v >$@


# --- generate Vivado Project ---

proj_name = $(BOARD)-riscv
proj_path = workspace/$(CONFIG)/vivado-$(proj_name)
proj_file = $(proj_path)/$(proj_name).xpr
bitstream = $(proj_path)/$(proj_name).runs/impl_1/riscv_wrapper.bit
vivado    = vivado -mode batch -nojournal -nolog -notrace -quiet

workspace/$(CONFIG)/system-$(BOARD).tcl: workspace/$(CONFIG)/rocket.vhdl workspace/$(CONFIG)/system-$(BOARD).v
	echo "set vivado_board_name $(BOARD)" >$@
	echo "set vivado_board_part $(BOARD_PART)" >>$@
	echo "set xilinx_part $(XILINX_PART)" >>$@
	echo "set riscv_clock_frequency $(ROCKET_FREQ).0" >>$@
	echo 'set script_folder [file dirname [file normalize [info script]]]' >>$@
	echo 'cd $$script_folder' >>$@
	echo 'source ../../vivado.tcl' >>$@

vivado-tcl: workspace/$(CONFIG)/system-$(BOARD).tcl

$(proj_file): vivado-tcl
	rm -rf $(proj_path)
	$(vivado) -source workspace/$(CONFIG)/system-$(BOARD).tcl

vivado-project: $(proj_file)

$(proj_path)/make-bitstream.tcl: vivado-project
	echo "open_project $(proj_file)">$@
	echo "update_compile_order -fileset sources_1">>$@
	echo "launch_runs impl_1 -to_step write_bitstream -jobs 4">>$@
	echo "wait_on_run impl_1">>$@

$(bitstream): $(proj_path)/make-bitstream.tcl
	$(vivado) -source $(proj_path)/make-bitstream.tcl
	if find $(proj_path) -name "*.log" -exec cat {} \; | grep 'ERROR: ' ; then exit 1 ; fi

bitstream: $(bitstream)

vivado-gui: vivado-project
	vivado $(proj_file) &
