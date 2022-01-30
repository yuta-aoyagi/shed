DISK = try.qcow2
ORIG_DISK = openwrt-orig.img
QEMU = $(HOME)/work/build-qemu-6.0.1/qemu-6.0.1
QEMU_IMG = sh ../mingw.sh "$(QEMU)/build/qemu-img"
ORIG_DISK_GZ = /mnt/c/Users/$(USERNAME)/Downloads/openwrt-21.02.1-x86-64-generic-ext4-combined.img.gz

all: help # TODO: replace later

help:
	@echo "usage: make [all|help|disk]" >&2

disk: $(DISK)

$(DISK): $(ORIG_DISK)
	$(QEMU_IMG) create -f qcow2 -b "$<" "$@"

$(ORIG_DISK): $(ORIG_DISK_GZ)
	printf "a1d1416bb456815ec7c4543df08f0eb81d365796042c562e40a46ab07b0d514c *%s\\n" "$<" | \
	    sha256sum -c --strict
	zcat "$<" >"$@"
