# frozen_string_literal: true

require "tmpdir"

RSpec.describe "try_openwrt's Makefile" do
  it "has a target `help`" do
    Dir.mktmpdir nil, "." do |dir|
      err = "#{dir}/err"
      system "make help >#{dir}/out 2>#{err}"
      stderr = File.open(err, &:read)
      expect(stderr).to match(/usage.*make/)
    end
  end

  it "has a target to create a new disk image file" do
    pending "wip"
    Dir.mktmpdir nil, "." do |dir|
      system "make DISK=#{dir}/test.qcow2 disk >#{dir}/out 2>#{dir}/err"
      expect(File.writable?("#{dir}/test.qcow2")).to be(true)
    end
  end
end
