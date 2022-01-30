QEMU = $(HOME)/work/build-qemu-6.0.1/qemu-6.0.1

all: help # TODO: replace later

help:
	@echo "usage: make [all|help|srv|run]" >&2

srv:
	python -m http.server 20080 &

run:
	l_arg=`cygpath -m "$(QEMU)/pc-bios"` && \
	    sh ../mingw.sh "$(QEMU)/build/qemu-system-x86_64" -cdrom "/Users/$$USERNAME/Downloads/alpine-virt-3.14.2-x86_64.iso" -nographic -L "$$l_arg"
