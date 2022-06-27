#!/bin/bash
#
# You can emulate many clients with parameter give as
# 
# ./q-client.sh <N>
#
if [ ! -f ./env.mk ]; then
    echo "exit: you have no env.mk"
    exit
fi

. ./env.mk

ip3_base=9
  
cn=$1 # client number
: ${cn:="1"}

((port = port_base + cn))
((ip3 = ip3_base + cn))

CURRDIR=$(pwd)
QEMU_PATH=${CURRDIR}/kernel/emulate/qemu-5.2.0/build
export PATH=${QEMU_PATH}:/bin:/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin

#LINUX_VERSION=4.10.6
IMAGE=kernel/linux-${LINUX_VERSION}/obj/linux-x86-qemu-minimal/arch/x86/boot/bzImage
#IMAGE=kernel/linux-${LINUX_VERSION}/obj/linux-x86-qemu-defconfig/arch/x86/boot/bzImage
#IMAGE=kernel/linux-${LINUX_VERSION}/arch/i386/boot/bzImage
#IMAGE=kernel/linux-${LINUX_VERSION}/arch/x86/boot/bzImage
#IMAGE=kernel/linux-${LINUX_VERSION}.full/arch/x86/boot/bzImage
#IMAGE=kernel/linux-${LINUX_VERSION}/vmlinux

FS=${FS_CLIENT}.squashfs

QEMU=${QEMU_PATH}/qemu-system-x86_64
#QEMU=qemu-system-i386

expect_commands="
set timeout -1
log_user 0;
spawn sudo ${QEMU} \
    -nographic \
    -kernel ${IMAGE} -hda ${FS} \
    -append \
    \"console=ttyS0 root=/dev/sda rw\"

expect -re \"(Linux version .*\r)\"
puts $expect_out(1,string);
log_user 1;
interact
"

expect -c "${expect_commands//
/;}"

#sudo ${QEMU} -nographic \
#    -net nic,vlan=1 -net socket,vlan=1,connect=127.0.0.1:${port} \
#    -hda ${FS} -hdb ${FS} -kernel ${IMAGE} \
#    -append \
#    "console=ttyS0 root=/dev/hdb rw \
#     ip=192.168.${ip3}.2::192.168.${ip3}.1:255.255.255.0::eth0:off \
#     sb=0x220,5,1,5 ide3=noprobe ide4=noprobe ide5=noprobe clock=pit"

#    -nographic \
#echo sudo ${QEMU} -kernel ${IMAGE}
#sudo ${QEMU} \
#    -nographic \
#    -hda ${FS} \
#    -kernel ${IMAGE} \
#    -append "earlyprintk=serial,ttyS0 console=ttyS0 root=/dev/sda rw"
 #   -append "console=ttyS0 root=/dev/sda rw sb=0x220,5,1,5"

#sudo ${QEMU} \
#    -nographic \
#    -nic socket,connect=127.0.0.1:${port} \
#    -hda ${FS} -kernel ${IMAGE} \
#    -append \
#    "console=ttyS0 root=/dev/sda rw \
#    ip=192.168.${ip3}.2::192.168.${ip3}.1:255.255.255.0::eth0:off \
#     sb=0x220,5,1,5"
