#!/bin/bash
#
#
#                 +--------------------+
#                 |                    |
#                 |      Host PC       |
#                 +--------------------+
#                 | tap0 | tap1 |      |
#                 +--+------+----------+
#                    |      |
#                    |      |
#                 +--+------+---+------+
#             wan | eth0 | eth1 |      |
#                 +-------------+------+
#                 +-------------+      |     Qemu emulate router
#             lan | eth2 | eth3 |      |
#                 +---+------+--+------+
#                     |      |
#                     |      |
#      +-----------+  |   +--+---------+
#      | client 1  |--+   | client 2   |     Qemu emulate PCs
#      |           |      |            |
#      +-----------+      +------------+
#

# echo '1'> /proc/sys/net/ipv4/ip_forward
# iptables -t nat -A POSTROUTING -s 172.20.0.0/24 -o eth0 -j MASQUERADE

if [ ! -f ./env.mk ]; then
    echo "exit: you have no env.mk"
    exit
fi

. ./env.mk
((port1 = port_base + 1))
((port2 = port_base + 2))

CURRDIR=$(pwd)
QEMU_PATH=${CURRDIR}/kernel/emulate/qemu-5.2.0/build
export PATH=${QEMU_PATH}:/bin:/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin

IMAGE=kernel/linux-${LINUX_VERSION}/arch/x86_64/boot/bzImage
#IMAGE=bzImage

FS=${FS_ROUTER}.squashfs

type qemu-system-x86_64

QEMU=${QEMU_PATH}/qemu-system-x86_64
#QEMU=qemu-system-i386

# sudo ${QEMU} -s -S -nographic \
#     -net nic -net tap \
#     -net nic -net tap \
#     -net nic,vlan=1 -net socket,vlan=1,listen=:${port1} \
#     -net nic,vlan=2 -net socket,vlan=2,listen=:${port2} \
#     -hda ${FS} -hdb ${FS} -kernel ${IMAGE} \
#     -append "console=ttyS0 root=/dev/hdb rw sb=0x220,5,1,5 ide3=noprobe ide4=noprobe ide5=noprobe clock=pit"

# sudo ${QEMU} -s -S -nographic \
#      -net nic -net tap \
#      -net nic -net tap \
#      -net nic,vlan=1 -net socket,vlan=1,listen=:${port1} \
#      -net nic,vlan=2 -net socket,vlan=2,listen=:${port2} \
#      -hda ${FS} -hdb ${FS} -kernel ${IMAGE} \
#      -append "console=ttyS0 rw sb=0x220,5,1,5 clock=pit"

#sudo ${QEMU} \
#     -kernel ${IMAGE} \
#     -nographic \
#     -append "root=/dev/sda console=ttyS0 rw sb=0x220,5,1,5" \
#     -hda ${FS} \
#     -netdev tap,id=dev0 -device e1000,netdev=dev0 \
#     -fsdev local,security_model=passthrough,id=fsdev0,path=/tmp/fs \
#     -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare

sudo ${QEMU} \
     -kernel ${IMAGE} \
     -nographic \
     -append "root=/dev/sda console=ttyS0 rw sb=0x220,5,1,5" \
     -hda ${FS} \
     -nic tap,script=no,downscript=no \
     -nic tap,script=no,downscript=no \
     -nic socket,listen=:${port1} \
     -nic socket,listen=:${port2} \
     -fsdev local,security_model=passthrough,id=fsdev0,path=/tmp/fs \
     -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare
