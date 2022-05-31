DISK = try.qcow2
ORIG_DISK_QCOW2 = openwrt-orig.qcow2
QEMU = $(HOME)/work/build-qemu-6.0.1/qemu-6.0.1
QEMU_IMG = sh ../mingw.sh "$(QEMU)/build/qemu-img"
ORIG_DISK = openwrt-orig.img
ORIG_DISK_GZ = /mnt/c/Users/$(USERNAME)/Downloads/openwrt-21.02.1-x86-64-generic-ext4-combined.img.gz

all: help # TODO: replace later

help:
	@echo "usage: make [all|help|disk|info|run]" >&2

disk: $(DISK)

$(DISK): $(ORIG_DISK_QCOW2)
	$(QEMU_IMG) create -f qcow2 -b "$<" -F qcow2 "$@"
	$(QEMU_IMG) resize "$@" 420M

$(ORIG_DISK): $(ORIG_DISK_GZ)
	printf "a1d1416bb456815ec7c4543df08f0eb81d365796042c562e40a46ab07b0d514c *%s\\n" "$<" | \
	    sha256sum -c --strict
	$(MAKE) "DECOMPRESS_IN=$(ORIG_DISK_GZ)" "DECOMPRESS_OUT=$(ORIG_DISK)" decompress

info: $(DISK)
	$(QEMU_IMG) info --backing-chain "$(DISK)"

run:
	l_arg=`cygpath -m "$(QEMU)/pc-bios"` && \
	    sh ../mingw.sh "$(QEMU)/build/qemu-system-x86_64" -nographic -L "$$l_arg" "$(DISK)"

drv:
	ruby -W vm_driver.rb

srv:
	cd http; python -m http.server 40080 &

run2:
	l_arg=`cygpath -m "$(QEMU)/pc-bios"` && \
	    sh ../mingw.sh "$(QEMU)/build/qemu-system-x86_64" -m 192 -nographic -serial tcp:127.0.0.1:4444 -L "$$l_arg" "$(DISK)"

VERSION = 21.02.3
ORIG_DISK_QCOW2_2 = openwrt-$(VERSION)-orig.qcow2
ORIG_DISK2 = openwrt-$(VERSION)-orig.img
DL = /mnt/c/Users/$(USERNAME)/Downloads
ORIG_DISK_GZ_FILENAME = openwrt-$(VERSION)-x86-64-generic-ext4-combined.img.gz
ORIG_DISK_GZ2 = $(DL)/$(ORIG_DISK_GZ_FILENAME)

disk2: $(ORIG_DISK_QCOW2_2)
	$(MAKE) "ORIG_DISK_QCOW2=$(ORIG_DISK_QCOW2_2)" "$(DISK)"

$(ORIG_DISK2): $(ORIG_DISK_GZ2)
	cd "$(DL)" && \
	    grep -F "$(ORIG_DISK_GZ_FILENAME)" "openwrt-$(VERSION)/sha256sums" \
	    | sha256sum -cw --strict && \
	    gunzip -lv "$(ORIG_DISK_GZ_FILENAME)"
	$(MAKE) "DECOMPRESS_IN=$(ORIG_DISK_GZ2)" "DECOMPRESS_OUT=$(ORIG_DISK2)" decompress

decompress: $(DECOMPRESS_IN)
	try_zcat() { \
	  set +e && { zcat "$(DECOMPRESS_IN)" >"$(DECOMPRESS_OUT)"; } 2>&1; \
	  ret=$$?; echo X && return $$ret; \
	} && \
	expected() { \
	  LF=`echo && echo _` && LF=$${LF%_} && \
	  exp="$${LF}gzip: $(DECOMPRESS_IN): decompression OK, trailing garbage ignored$$LF" && \
	  [ "$$exp" = "$${msgX%X}" ]; \
	} && \
	msgX=`try_zcat`; ret=$$? && \
	if [ $$ret = 2 ] && expected; then \
	  echo a known warning is ignored. >&2; \
	else \
	  printf %s "$${msgX%X}" >&2 && \
	      set_status() { return "$$1"; } && set_status $$ret; \
	fi

.SUFFIXES: .img .qcow2
.img.qcow2:
	$(QEMU_IMG) convert -c -O qcow2 "$<" "$@"
	$(QEMU_IMG) compare -s "$<" "$@" || $(QEMU_IMG) compare "$<" "$@"
