
* Usage

** Prepare

This package provide a embedded linux study environment. I use 'qemu'
as a emulator to build this system.

The environment has a router and some clients.

                 +--------------------+
                 |                    |
                 |      Host PC       |
                 +--------------------+
                 | tap0 | tap1 |      |
                 +--+------+----------+
                    |      |
                    |      |
                 +--+------+---+------+
             wan | eth0 | eth1 |      |
                 +-------------+------+
                 +-------------+      |     Qemu emulate router
             lan | eth2 | eth3 |      |
                 +---+------+--+------+
                     |      |
                     |      |
      +-----------+  |   +--+---------+
      | client 1  |--+   | client 2   |     Qemu emulate PCs
      |           |      |            |
      +-----------+      +------------+



To use this package, you need install qemu in your linux pc first with
apt-get utility:

  apt-get install qemu

Then in the top dir do

  make prepare

'make prepare' will extract the rootfs for the router and client. 

When you finish that, congratulations, you can build your system now.

** F/W build

- Build the kernel

First, you need download the linux kernel source and extract to
directory 'kernel'.

A working mirror site for downloading is like following:

http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/

If you will use squashfs, then you need download squashfs from
http://squashfs.sourceforge.net/ and patch it to your kernel. After
that, do 'make menuconfig' to add squashfs support then build the
kernel.

If you do not use squashfs, then just do the following commands

  cd kernel/linux-<version>
  make bzImage
  
- Build the file system

  make src

- Build the router f/w

Since the libraries in the fs are copyed from my PC, you need update
to yours with the script 'tools/scripts/build-glibc-lib.sh' when first
time build.

  cd rootfs; 

  make fs-router

- Build the client f/w

  make fs-client

** Start

- Router start

  ./q-router.sh

- Client start

  ./q-client.sh
  

* Appdendix

** Kernel Compile FAQs

*** HOWTO build kernel with cross compile?

e.g.

make ARCH=x86 CROSS_COMPILE=/home/fog/study/rt/br/buildroot-2015.08.1/output/host/usr/bin/i686-buildroot-linux-gnu-

*** HOWTO support Ctrl-C ?

Patch kernel with following code:

----------------------------------------------------------------------------------------
diff -urN linux-2.6.16.cur/drivers/char/tty_io.c linux-2.6.16.orig/drivers/char/tty_io.c
--- linux-2.6.16.cur/drivers/char/tty_io.c      2006-10-23 23:02:28.000000000 +0800
+++ linux-2.6.16.orig/drivers/char/tty_io.c     2006-10-23 23:02:43.000000000 +0800
@@ -2067,7 +2067,7 @@
                if (driver) {
                        /* Don't let /dev/console block */
                        filp->f_flags |= O_NONBLOCK;
-                       noctty = 1;
+                       /* noctty = 1; */
                        goto got_driver;
                }
                up(&tty_sem);


*** Error message "linux/compiler-gcc7.h: No such file or directory"

When I compiling linux-3.18.21 on ubuntu 18.04 which with gcc7.5, I
meet such a error message.  

After googling, I found it's caused by the compatiblility with gcc and
kernel. In kernel's include/linux directory, we can find
compiler-gcc[45].h, while gcc7 needs a header file like
compiler-gcc7.h. 

So, the solution is simple, just copy compiler-gcc5.h to
compiler-gcc7.h, it's done.

*** Error message "kernel/bounds.c:1:0: error: code model kernel does not support PIC mode"

The issue is with your gcc installation, in gcc 6+ versions PIE(
position independent executables) is enabled by default. So in order
to compile you need to disable it. Even gcc 5 has the issue. This is a
known bug for gcc.

So far there is no official patch from gcc side, so the workaround is
to patch the Makefile of kernel source.

patch file is as following:

#+BEGIN_SRC diff
--- Makefile.org	2021-03-12 10:08:14.007697730 +0800
+++ Makefile	2021-03-12 10:10:03.274706755 +0800
@@ -607,6 +607,12 @@
 # Defaults to vmlinux, but the arch makefile usually adds further targets
 all: vmlinux
 
+# force no-pie for distro compilers that enable pie by default
+KBUILD_CFLAGS += $(call cc-option, -fno-pie)
+KBUILD_CFLAGS += $(call cc-option, -no-pie)
+KBUILD_AFLAGS += $(call cc-option, -fno-pie)
+KBUILD_CPPFLAGS += $(call cc-option, -fno-pie)
+
 include $(srctree)/arch/$(SRCARCH)/Makefile
 
 KBUILD_CFLAGS	+= $(call cc-option,-fno-delete-null-pointer-checks,)
#+END_SRC

** QEMU commands

   C-a x         quit
