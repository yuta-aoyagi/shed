QEMU = $(HOME)/work/build-qemu-6.0.1/qemu-6.0.1
DISK = try.qcow2
SEED_PORT = 20080
SSH_PORT = 20022

all: help

help:
	@echo "usage: make {all|help|srv|disk|run|ssh}" >&2

srv:
	cd seed; python -m http.server $(SEED_PORT) &
	ruby -W receiver.rb &

disk: $(DISK)

$(DISK):
	sh mingw.sh "$(QEMU)/build/qemu-img" create -f qcow2 -b "/Users/$$USERNAME/Downloads/amzn2-kvm-2.0.20211201.0-x86_64.xfs.gpt.qcow2" -F qcow2 "$@"

run:
	l_arg=`cygpath -m "$(QEMU)/pc-bios"` && \
	    sh mingw.sh "$(QEMU)/build/qemu-system-x86_64" -m 512 -nographic -smbios type=1,serial="ds=nocloud-net;s=http://10.0.2.2:$(SEED_PORT)/" -nic user,hostfwd=::$(SSH_PORT)-:22 -L "$$l_arg" "$(DISK)"

ssh:
	ssh -CTi ~/.ssh/id_ed25519_try_qemu -oUserKnownHostsFile=~/.ssh/known_hosts_qemu_try "-p$(SSH_PORT)" ec2-user@localhost
