qemu-system-riscv64 -machine virt -m 60G -nographic \
-bios ../opensbi/build/platform/vivado-risc-v/firmware/payloads/fw_payload.bin \
-smp cores=8 \
-device virtio-net-device,netdev=net0 \
-netdev user,id=net0,tftp=tftp,hostfwd=tcp::2222-:22  \
-drive if=none,file=../debian-riscv64/debian-riscv64.sd.img,format=raw,id=mydisk \
-device ich9-ahci,id=ahci -device ide-hd,drive=mydisk,bus=ahci.0 \
-device virtio-rng-pci
