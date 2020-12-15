apt-install:
	sudo apt update
	sudo apt upgrade
	sudo apt install default-jdk device-tree-compiler python curl gawk \
	 libtinfo5 libmpc-dev gcc gcc-riscv64-linux-gnu gcc-8-riscv64-linux-gnu flex bison

# skip submodules which are not needed and take long time to update
SKIP_SUBMODULES = torture software/gemmini-rocc-tests software/onnxruntime-riscv

update-submodules:
	git $(foreach m,$(SKIP_SUBMODULES),-c submodule.$(m).update=none) submodule update --init --force --recursive

clean-submodules:
	git submodule foreach --recursive git clean -xfdq

clean:
	git submodule foreach --recursive git clean -xfdq
	sudo rm -rf debian-riscv64

# --- download gcc, initrd and rootfs from github.com ---

workspace/gcc/riscv:
	mkdir -p workspace/gcc
	cd workspace/gcc &&\
	  curl --netrc --location --header 'Accept: application/octet-stream' \
	  https://api.github.com/repos/eugene-tarassov/vivado-risc-v/releases/assets/18060315 |\
	  tar xz

debian-riscv64/initrd:
	mkdir -p debian-riscv64
	curl --netrc --location --header 'Accept: application/octet-stream' \
	  https://api.github.com/repos/eugene-tarassov/vivado-risc-v/releases/assets/25545769 \
	  -o $@

debian-riscv64/rootfs.tar.gz:
	mkdir -p debian-riscv64
	curl --netrc --location --header 'Accept: application/octet-stream' \
	  https://api.github.com/repos/eugene-tarassov/vivado-risc-v/releases/assets/25545771 \
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

BOARD ?= nexys-video
CONFIG ?= rocket64b2
CONFIG_SCALA := $(subst rocket,Rocket,$(CONFIG))
JAVA_OPTIONS =

ifeq ($(BOARD),nexys-video)
  BOARD_PART  ?= digilentinc.com:nexys_video:part0:1.1
  XILINX_PART ?= xc7a200tsbg484-1
  CFG_DEVICE  ?= SPIx4 -size 256
  MEMORY_SIZE ?= 0x20000000
  ETHER_MAC   ?= 00 0a 35 00 00 01
  ETHER_PHY   ?= rgmii
endif

ifeq ($(BOARD),genesys2)
  BOARD_PART  ?= digilentinc.com:genesys2:part0:1.1
  XILINX_PART ?= xc7k325tffg900-2
  CFG_DEVICE  ?= SPIx4 -size 256
  MEMORY_SIZE ?= 0x40000000
  ETHER_MAC   ?= 00 0a 35 00 00 02
  ETHER_PHY   ?= rgmii-rxid
endif

ifeq ($(BOARD),vc707)
  BOARD_PART  ?= xilinx.com:vc707:part0:1.4
  XILINX_PART ?= xc7vx485tffg1761-2
  CFG_DEVICE  ?= bpix16 -size 128
  MEMORY_SIZE ?= 0x40000000
  ETHER_MAC   ?= 00 0a 35 00 00 00
  ETHER_PHY   ?= sgmii
endif

# valid ROCKET_FREQ values (MHz): 125 100 80 62.5 50 40 31.25 25 20
ROCKET_FREQ ?= $(shell awk '$$3 != "" && "$(BOARD)" ~ $$1 && "$(CONFIG_SCALA)" ~ ("^" $$2 "$$") {print $$3; exit}' board/rocket-freq)
ROCKET_FREQ_KHZ := $(shell echo - | awk '{print $(ROCKET_FREQ) * 1000}')

ifeq ($(findstring Rocket64,$(CONFIG_SCALA)),)
  CROSS_COMPILE_NO_OS_TOOLS = $(realpath workspace/gcc/riscv/bin)/riscv32-unknown-elf-
  CROSS_COMPILE_NO_OS_FLAGS = -march=rv32im -mabi=ilp32
else
  CROSS_COMPILE_NO_OS_TOOLS = $(realpath workspace/gcc/riscv/bin)/riscv64-unknown-elf-
  CROSS_COMPILE_NO_OS_FLAGS = -march=rv64im -mabi=lp64
endif

SBT := java -Xmx4G -Xss8M $(JAVA_OPTIONS) -jar $(realpath rocket-chip/sbt-launch.jar)
CHISEL_SRC := $(foreach path, src/main rocket-chip/src/main riscv-boom/src/main, $(shell test -d $(path) && find $(path) -iname "*.scala"))

ROCKET_CLASSES = \
  target/scala-2.12/classes \
  rocket-chip/target/scala-2.12/classes \
  rocket-chip/chisel3/target/scala-2.12/classes \
  rocket-chip/chisel3/core/target/scala-2.12/classes \
  rocket-chip/chisel3/macros/target/scala-2.12/classes

SPACE := $(subst ,, )

FIRRTL_SRC := $(shell test -d rocket-chip/firrtl/src/main && find rocket-chip/firrtl/src/main -iname "*.scala")
FIRRTL_JAR = rocket-chip/firrtl/utils/bin/firrtl.jar
FIRRTL = java -Xmx12G -Xss8M $(JAVA_OPTIONS) -cp $(FIRRTL_JAR):$(subst $(SPACE),:,$(strip $(ROCKET_CLASSES))) firrtl.stage.FirrtlMain

$(FIRRTL_JAR): $(FIRRTL_SRC)
	make -C rocket-chip/firrtl SBT="$(SBT)" root_dir=$(realpath rocket-chip/firrtl) build-scala
	touch $(FIRRTL_JAR)

# Generate default device tree - not including peripheral devices or board specific data 
workspace/$(CONFIG)/system.dts: $(FIRRTL_JAR) $(CHISEL_SRC) rocket-chip/bootrom/bootrom.img
	cd rocket-chip && git reset --hard && patch -p1 <../patches/rocket-chip.patch
	mkdir -p workspace/$(CONFIG)/tmp
	cp rocket-chip/bootrom/bootrom.img workspace/bootrom.img
	$(SBT) "runMain freechips.rocketchip.system.Generator -td workspace/$(CONFIG)/tmp -T Vivado.RocketSystem -C Vivado.$(CONFIG_SCALA)"
	mv workspace/$(CONFIG)/tmp/Vivado.$(CONFIG_SCALA).anno.json workspace/$(CONFIG)/system.anno.json
	mv workspace/$(CONFIG)/tmp/Vivado.$(CONFIG_SCALA).dts workspace/$(CONFIG)/system.dts
	rm -rf workspace/$(CONFIG)/tmp

# Generate board specific device tree and FIR
workspace/$(CONFIG)/system-$(BOARD)/Vivado.$(CONFIG_SCALA).fir: workspace/$(CONFIG)/system.dts $(wildcard bootrom/*) workspace/gcc/riscv
	mkdir -p workspace/$(CONFIG)/system-$(BOARD)
	cat workspace/$(CONFIG)/system.dts bootrom/bootrom.dts >bootrom/system.dts
	sed -i "s#reg = <0x80000000 0x.*>#reg = <0x80000000 $(MEMORY_SIZE)>#g" bootrom/system.dts
	sed -i "s#clock-frequency = <[0-9]*>#clock-frequency = <$(ROCKET_FREQ_KHZ)000>#g" bootrom/system.dts
	sed -i "s#timebase-frequency = <[0-9]*>#timebase-frequency = <$(ROCKET_FREQ_KHZ)0>#g" bootrom/system.dts
	sed -i "s#local-mac-address = \[.*\]#local-mac-address = [$(ETHER_MAC)]#g" bootrom/system.dts
	sed -i "s#phy-mode = \".*\"#phy-mode = \"$(ETHER_PHY)\"#g" bootrom/system.dts
	make -C bootrom CROSS_COMPILE="$(CROSS_COMPILE_NO_OS_TOOLS)" CFLAGS="$(CROSS_COMPILE_NO_OS_FLAGS)" clean bootrom.img
	cp bootrom/system.dts workspace/$(CONFIG)/system-$(BOARD).dts
	cp bootrom/bootrom.img workspace/bootrom.img
	$(SBT) "runMain freechips.rocketchip.system.Generator -td workspace/$(CONFIG)/system-$(BOARD) -T Vivado.RocketSystem -C Vivado.$(CONFIG_SCALA)"

# Generate Rocket SoC HDL
workspace/$(CONFIG)/system-$(BOARD).v: workspace/$(CONFIG)/system-$(BOARD)/Vivado.$(CONFIG_SCALA).fir
	$(FIRRTL) -i $< -o system-$(BOARD).v -X verilog --infer-rw RocketSystem --repl-seq-mem \
	  -c:RocketSystem:-o:workspace/$(CONFIG)/system.conf \
	  -faf workspace/$(CONFIG)/system.anno.json \
	  -td workspace/$(CONFIG)/ \
	  -fct firrtl.passes.InlineInstances
	rocket-chip/scripts/vlsi_mem_gen workspace/$(CONFIG)/system.conf >workspace/$(CONFIG)/srams.v

# Generate Rocket SoC wrapper for Vivado
workspace/$(CONFIG)/rocket.vhdl: workspace/$(CONFIG)/system-$(BOARD).v
	mkdir -p vhdl-wrapper/bin
	javac -g -nowarn \
	  -sourcepath vhdl-wrapper/src -d vhdl-wrapper/bin \
	  -classpath vhdl-wrapper/antlr-4.8-complete.jar \
	  vhdl-wrapper/src/net/largest/riscv/vhdl/Main.java
	java -Xmx4G -Xss8M $(JAVA_OPTIONS) -cp \
	  vhdl-wrapper/src:vhdl-wrapper/bin:vhdl-wrapper/antlr-4.8-complete.jar \
	  net.largest.riscv.vhdl.Main \
	  workspace/$(CONFIG)/system-$(BOARD).v >$@

# --- utility make targets to run SBT command line ---

.PHONY: sbt rocket-sbt

sbt:
	$(SBT)

rocket-sbt:
	cd rocket-chip && $(SBT)

# --- generate Vivado Project ---

.PHONY: vivado-tcl vivado-project vivado-gui bitstream

proj_name = $(BOARD)-riscv
proj_path = workspace/$(CONFIG)/vivado-$(proj_name)
proj_file = $(proj_path)/$(proj_name).xpr
bitstream = $(proj_path)/$(proj_name).runs/impl_1/riscv_wrapper.bit
mcs_file  = workspace/$(CONFIG)/$(proj_name).mcs
vivado    = env XILINX_LOCAL_USER_DATA=no vivado -mode batch -nojournal -nolog -notrace -quiet

workspace/$(CONFIG)/system-$(BOARD).tcl: workspace/$(CONFIG)/rocket.vhdl workspace/$(CONFIG)/system-$(BOARD).v
	echo "set vivado_board_name $(BOARD)" >$@
	echo "set vivado_board_part $(BOARD_PART)" >>$@
	echo "set xilinx_part $(XILINX_PART)" >>$@
	echo "set riscv_clock_frequency $(ROCKET_FREQ)" >>$@
	echo 'set script_folder [file dirname [file normalize [info script]]]' >>$@
	echo 'cd $$script_folder' >>$@
	echo 'source ../../vivado.tcl' >>$@

vivado-tcl: workspace/$(CONFIG)/system-$(BOARD).tcl

$(proj_file): workspace/$(CONFIG)/system-$(BOARD).tcl
	if [ ! -e $(proj_path) ] ; then $(vivado) -source workspace/$(CONFIG)/system-$(BOARD).tcl ; fi

vivado-project: $(proj_file)

# --- generate FPGA bitstream ---

$(proj_path)/make-bitstream.tcl: $(proj_file)
	echo "open_project $(proj_file)">$@
	echo "update_compile_order -fileset sources_1">>$@
	echo "launch_runs impl_1 -to_step write_bitstream -jobs 4">>$@
	echo "wait_on_run impl_1">>$@
	echo "write_cfgmem -format mcs -interface $(CFG_DEVICE) -loadbit \"up 0x0 $(bitstream)\" -file $(mcs_file) -force">>$@

$(bitstream): $(proj_path)/make-bitstream.tcl workspace/$(CONFIG)/rocket.vhdl
	$(vivado) -source $(proj_path)/make-bitstream.tcl
	if find $(proj_path) -name "*.log" -exec cat {} \; | grep 'ERROR: ' ; then exit 1 ; fi

bitstream: $(bitstream)

# --- launch Vivado GUI ---

vivado-gui: $(proj_file)
	vivado $(proj_file) &
