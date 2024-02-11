# frozen_string_literal: true

require "tempfile"
require "tmpdir"

RSpec.describe "try_openwrt's Makefile" do
  it "has a target `help`" do
    Tempfile.open("", ".") do |err|
      err.close
      output = `make help 2>#{err.path}`
      expect(output).to match(/usage.*make /)
    end
  end

  describe "default target" do
    it "creates a disk image" do
      pending
      Dir.mktmpdir nil, "." do |dir|
        Tempfile.open(["", ".qcow2"], ".") do |img|
          img.close
          system "make DISK=#{img.path} >#{dir}/out 2>#{dir}/err"
          expect(img.size).to be > 1000
        end
      end
    end
  end
end
