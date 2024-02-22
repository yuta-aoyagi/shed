#!/usr/bin/ruby -W
# frozen_string_literal: true

ORIG_DISK = "ORIG_DISK"

def execute(env, kernel)
  %r{\A[-.0-9A-Z_a-z][-./0-9A-Z_a-z]*\z} =~ (od = env.fetch(ORIG_DISK)) ||
    raise("Currently tests can only be run with relative ORIG_DISK")

  env[ORIG_DISK] = "../#{od}"
  kernel.system "make -f ../Makefile DISK=disk.qcow2"
end

execute ENV, Kernel if $PROGRAM_NAME == __FILE__
