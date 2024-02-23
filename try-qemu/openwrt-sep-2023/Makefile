.POSIX:

QEMU_IMG = qemu-img

all: disk

help:
	@echo "usage: ORIG_DISK=disk-orig.qcow2 make {DISK=disk.qcow2 [all|disk]|check}"
	@echo "  or:  make help"

disk: $(DISK)

$(DISK): $(ORIG_DISK)
	$(QEMU_IMG) create -f qcow2 -b "$(ORIG_DISK)" -F qcow2 "$@"

check:
	bundle exec rubocop -S
	bundle exec rspec
