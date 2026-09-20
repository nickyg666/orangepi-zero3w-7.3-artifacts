setenv bootargs console=ttyS0,115200 earlycon=uart,mmio32,0x2500000 root=PARTUUID=486ea4ae-01 rootfstype=ext4 rootwait rw modprobe.blacklist=aic8800_btlpm loglevel=7
ext4load mmc 0:1 0x41000000 boot/mainline/Image
cp.b 0x41000000 0x40200000 0x278B808
ext4load mmc 0:1 0x43000000 boot/mainline/sun60i-a733-orangepi-zero3w.dtb
fdt addr 0x43000000
fdt resize 65536
booti 0x40200000 - 0x43000000
