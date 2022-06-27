ifndef TOPDIR
TOPDIR = $(shell (cd ../ && pwd -P))
endif

ifndef INSTALL_ROOT
INSTALL_ROOT=$(TOPDIR)/rootfs.router
endif

ifndef KERNEL_DIR
#KERNEL_DIR=$(TOPDIR)/linux-2.6.21
#KERNEL_DIR=$(TOPDIR)/linux-2.6.16
KERNEL_DIR=$(TOPDIR)/linux-3.18.21
endif

MAKE=make
CC=gcc -m32

export TOPDIR INSTALL_ROOT KERNEL_DIR CC MAKE

CONFIG_busybox=y
CONFIG_iproute2=n
CONFIG_dnrd=n

SUBDIRS-y = 
SUBDIRS-n =

SUBDIRS-$(CONFIG_busybox) += busybox-1.32.1
SUBDIRS-$(CONFIG_iproute2) += iproute2
#SUBDIRS-$(CONFIG_dnrd) += dnrd-2.17.2

all: $(SUBDIRS-y)

$(SUBDIRS-y): prebuild
	@for i in $(SUBDIRS-y) ; \
		do echo -e "\033[47;36m 	compile for $$i \033[0m"; \
		$(MAKE) -C $$i || exit 1; \
	done

prebuild:
	@echo "no prebuild needed."


install:
	@for i in $(SUBDIRS-y) ; \
		do echo -e "\033[47;36m 	install $$i \033[0m"; \
$(MAKE) -C $$i CONFIG_PREFIX=$(INSTALL_ROOT) install || exit 1; \
	done

clean:
	@for i in $(SUBDIRS-y) ; do $(MAKE) -C $$i clean || exit 1; done
