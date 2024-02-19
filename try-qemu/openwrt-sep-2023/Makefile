.POSIX:

QEMU_IMG = qemu-img

all: disk

help:
	@echo "usage: make {ORIG_DISK=disk-orig.qcow2 {DISK=disk.qcow2 [all|disk]|check}|help}"

disk: $(DISK)

$(DISK): $(ORIG_DISK)
	$(QEMU_IMG) create -f qcow2 -b "$(ORIG_DISK)" -F qcow2 "$@"

check:
	bundle exec rubocop -S
	bundle exec rspec
