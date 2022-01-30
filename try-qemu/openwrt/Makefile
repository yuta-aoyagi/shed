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

$(ORIG_DISK_QCOW2): $(ORIG_DISK)
	$(QEMU_IMG) convert -c -O qcow2 "$<" "$@"

$(ORIG_DISK): $(ORIG_DISK_GZ)
	printf "a1d1416bb456815ec7c4543df08f0eb81d365796042c562e40a46ab07b0d514c *%s\\n" "$<" | \
	    sha256sum -c --strict
	try_zcat() { \
	  set +e && { zcat "$<" >"$@"; } 2>&1; ret=$$?; echo X && return $$ret; \
	} && \
	expected() { \
	  LF=`echo && echo _` && LF=$${LF%_} && \
	  exp="$${LF}gzip: $<: decompression OK, trailing garbage ignored$$LF" && \
	  [ "$$exp" = "$${msgX%X}" ]; \
	} && \
	if msgX=`try_zcat`; then \
	  printf %s "$${msgX%X}" >&2; \
	elif ret=$$? && [ $$ret = 2 ] && expected; then \
	  echo a known warning is ignored. >&2; \
	else \
	  printf %s "$${msgX%X}" >&2 && \
	      set_status() { return "$$1"; } && set_status $$ret; \
	fi

info: $(DISK)
	$(QEMU_IMG) info --backing-chain "$(DISK)"

run:
	l_arg=`cygpath -m "$(QEMU)/pc-bios"` && \
	    sh ../mingw.sh "$(QEMU)/build/qemu-system-x86_64" -nographic -L "$$l_arg" "$(DISK)"
