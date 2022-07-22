obj-m += procfs1.o
#ccflags-y := -Wno-declaration-after-statement -std=gnu99
ccflags-y := -g -DDEBUG

.PHONY: all clean

PWD := $(CURDIR)

all:
	$(MAKE) -C '$(KERNEL_DIR)' M='$(PWD)' ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) V=1 modules

clean:
	#$(MAKE) -C '$(KERNEL_DIR)' M='$(PWD)' clean
	rm *.o *.ko

install:
	cp procfs1.ko $(INSTALL_ROOT)/lib
