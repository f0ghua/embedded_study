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

QEMU_PATH=/home/fog/study/rt/embedded_study/kernel/emulate/qemu-7.0.0/install/bin
export PATH=${QEMU_PATH}:/bin:/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin

IMAGE=kernel/linux-${LINUX_VERSION}/arch/x86/boot/bzImage

FS=${FS_HOST}.squashfs

QEMU=qemu-system-i386

$QEMU --version
echo "kernel=$IMAGE"
##	-nographic
##   -serial tcp::4446,server,telnet

#${QEMU} ${DEBUG_OPT} -nographic\
#    -kernel ${IMAGE} -hda ${FS} \
#    -append \
#    "console=ttyS0 root=/dev/sda rw"

##-chardev stdio,id=seabios -device isa-debugcon,iobase=0x402,chardev=seabios
#exit

expect_commands="
set timeout -1
log_user 0;
spawn ${QEMU} ${DEBUG_OPT} \
    -nographic \
    -kernel ${IMAGE} -hda ${FS} \
    -append \
    \"console=ttyS0 root=/dev/sda rw\" \
     -fsdev local,security_model=passthrough,id=fsdev0,path=`pwd`/virtio_dir \
     -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare

expect -re \"(Linux version .*\r)\"
puts $expect_out(1,string);
log_user 1;
interact
"

expect -c "${expect_commands//
/;}"

#sudo ${QEMU} ${DEBUG_OPT} -nographic \
#    -net nic,model=rtl8139 -net tap \
#    -hda ${FS} -hdb ${FS} -kernel ${IMAGE} \
#    -append \
#    "console=ttyS0 root=/dev/hdb rw \
#     sb=0x220,5,1,5 ide3=noprobe ide4=noprobe ide5=noprobe clock=pit"

