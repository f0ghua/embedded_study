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

while getopts ":d" Option
do
    case $Option in
    d ) DEBUG_OPT="-s -S";;
    * ) ;;
    esac
done
shift $((OPTIND - 1))

QEMU_PATH=/home/fog/study/kernel/emulate/qemu-0.9.1
export PATH=${QEMU_PATH}:/bin:/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin

IMAGE=kernel/linux-${LINUX_VERSION}/arch/i386/boot/bzImage

FS=${FS_HOST}.squashfs

QEMU=qemu

sudo ${QEMU} ${DEBUG_OPT} -nographic \
    -net nic,model=rtl8139 -net tap \
    -hda ${FS} -hdb ${FS} -kernel ${IMAGE} \
    -append \
    "console=ttyS0 root=/dev/hdb rw \
     sb=0x220,5,1,5 ide3=noprobe ide4=noprobe ide5=noprobe clock=pit"

