if [ ! -e debian-riscv64/debian-riscv64.sd.img ]
then
    ./mk-sd-image
    make u-boot-qemu
    make opensbi-qemu
fi

qemu-system-riscv64 -machine virt -m 8G -nographic \
-bios qemu/opensbi/build/platform/generic/firmware/fw_payload.bin \
-smp cores=1 \
-device virtio-net-device,netdev=net0 \
-netdev user,id=net0,tftp=tftp,hostfwd=tcp::2222-:22  \
-drive if=none,file=debian-riscv64/debian-riscv64.sd.img,format=raw,id=mydisk \
-device ich9-ahci,id=ahci -device ide-hd,drive=mydisk,bus=ahci.0 \
-device virtio-rng-pci
