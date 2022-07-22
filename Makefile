include env.mk

TOPDIR:=$(shell pwd)

TOOL_DIR:=$(TOPDIR)/tools
FS_HOST_DIR=$(TOPDIR)/rootfs/$(FS_HOST)
FS_ROUTER_DIR=$(TOPDIR)/rootfs/$(FS_ROUTER)
FS_CLIENT_DIR=$(TOPDIR)/rootfs/$(FS_CLIENT)
KERNEL_DIR:=$(TOPDIR)/kernel/linux-$(LINUX_VERSION)

INSTALL_ROOT:=$(FS_HOST_DIR)

export TOPDIR TOOL_DIR INSTALL_ROOT KERNEL_DIR CROSS_COMPILE ARCH


#MKFS_TOOL=$(TOOL_DIR)/squashfs/mksquashfs3.1-r2
MKFS_TOOL=mksquashfs


all:
	@echo "please select 'src/fs-router/fs-client' to build."

.PHONY: src

prepare:
#	@sudo cp $(TOOL_DIR)/qemu/qemu-ifup /etc/
	cd $(TOPDIR)/rootfs; \
	rm -rf rootfs.*; \
	sudo tar -zxf $(FS_HOST).tar.gz; \
	sudo tar -zxf $(FS_ROUTER).tar.gz; \
	sudo tar -zxf $(FS_CLIENT).tar.gz

src:
	make -C fs-src

fs-host:
	make INSTALL_ROOT:=$(FS_HOST_DIR) -C fs-src install
#   	first time build, we need update libraries
	if [ ! -e "fs-host.squashfs" ];then \
		./tools/scripts/build-glibc-lib.sh $(FS_HOST_DIR);\
	fi
	rm -f $(FS_HOST).squashfs
	$(MKFS_TOOL) $(FS_HOST_DIR) $(FS_HOST).squashfs

fs-router:
	make INSTALL_ROOT:=$(FS_ROUTER_DIR) -C fs-src install
#	first time build, we need update libraries
	# if [ ! -e "fs-router.squashfs" ];then \
	# 	./tools/scripts/build-glibc-lib.sh $(FS_ROUTER_DIR);\
	# fi
	# rm -f $(FS_ROUTER).squashfs
	$(MKFS_TOOL) $(FS_ROUTER_DIR) $(FS_ROUTER).squashfs

fs-client:
	make INSTALL_ROOT:=$(FS_CLIENT_DIR) -C fs-src install
	if [ ! -e "fs-client.squashfs" ];then \
		./tools/scripts/build-glibc-lib.sh $(FS_CLIENT_DIR);\
	fi
	rm -f $(FS_CLIENT).squashfs
	$(MKFS_TOOL) $(FS_CLIENT_DIR) $(FS_CLIENT).squashfs

clean:
	make -C fs-src clean

distclean: clean
#	make -C $(KERNEL_DIR) clean
	rm -f fs.*.squashfs
	cd $(TOPDIR)/rootfs; \
	rm -rf ${FS_HOST_DIR} ${FS_CLIENT_DIR} ${FS_ROUTER_DIR}
