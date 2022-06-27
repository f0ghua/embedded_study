#!/bin/bash
#
# This script will help you to copy necessary libraries from your OS
# to root fs
#

if [ $# -ne 1 ];then
    echo "Usage: $0 <rootfs dir>"
fi

fs_dir="$1"

if [ ! -d "${fs_dir}" ];then
    echo "Error: the directory is not exist."
fi

#pwd=$(pwd)
#fs_dir=${pwd}/rootfs.router

exec_dirs="${fs_dir}/usr/local/bin/ ${fs_dir}/bin"
exec_files=$(find ${fs_dir} -path ${fs_dir}/lib -prune -o -type f -print | file -f - | grep ELF | cut -d':' -f1)

echo ${exec_files}

for ef in ${exec_files};do
    echo file: $ef --------------
    exec_libs=$(ldd ${ef} | grep -v checking | grep lib | sed 's/.*\=>//g' | awk '{$1=$1}{print $1}')
    echo libs:$exec_libs

    for fpath in ${exec_libs};do
        echo fpath:$fpath
        fdir=$(dirname $fpath)
        fname=${fpath##*/}
        #if [ ! -f ${fs_dir}/${fpath} ];then
            # If it's a soft link, copy the hard file also
            if [ -h $fpath ];then
                rl=$(readlink -f $fpath);
                echo "real link: $rl"
                rlfdir=$(dirname $rl)
                rlfname=${rl##*/}
                mkdir -p ${fs_dir}/${rlfdir} && cp -a $rl ${fs_dir}/${rl}
                echo "cp -a $rl ${fs_dir}/${rl}"
            fi
            mkdir -p ${fs_dir}/${fdir} && cp -a $fpath ${fs_dir}/${fpath}
            echo "cp -a $fpath ${fs_dir}/${fpath}"
        #fi
    done
done
