.POSIX:

QEMU_IMG = qemu-img

all: help # TODO: replace later

help:
	@echo "usage: make [all|help|check]" >&2

check:
	bundle exec rubocop -S
	bundle exec rspec

disk: $(DISK)

$(DISK): $(ORIG_DISK)
	$(QEMU_IMG) create -f qcow2 -b "$(ORIG_DISK)" -F qcow2 "$@"
