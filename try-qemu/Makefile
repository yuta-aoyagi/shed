QEMU = $(HOME)/work/build-qemu-6.0.1/qemu-6.0.1
DISK = try.qcow2

run:
	l_arg=`cygpath -m "$(QEMU)/pc-bios"` && \
	    sh mingw.sh "$(QEMU)/build/qemu-system-x86_64" -m 512 -drive file=$(DISK) -drive file=fat:seed,format=raw,read-only=on -nographic -L "$$l_arg"

disk: $(DISK)

$(DISK):
	sh mingw.sh "$(QEMU)/build/qemu-img" create -f qcow2 -b "/Users/$$USERNAME/Downloads/amzn2-kvm-2.0.20211201.0-x86_64.xfs.gpt.qcow2" -F qcow2 $@
