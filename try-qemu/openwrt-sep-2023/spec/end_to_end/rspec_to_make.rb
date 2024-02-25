#!/usr/bin/ruby -W
# frozen_string_literal: true

BASE_DISK = "BASE_DISK"

def execute(env, kernel)
  %r{\A[-.0-9A-Z_a-z][-./0-9A-Z_a-z]*\z} =~ (bd = env.fetch(BASE_DISK)) ||
    raise("Currently tests can only be run with relative BASE_DISK")

  env[BASE_DISK] = "../#{bd}"
  kernel.system "make -f ../Makefile DISK=disk.qcow2"
end

execute ENV, Kernel if $PROGRAM_NAME == __FILE__
