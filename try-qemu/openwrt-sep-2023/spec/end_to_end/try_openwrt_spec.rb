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
    Dir.mktmpdir nil, "." do |dir|
      img = "#{dir}/test.qcow2"
      system "make DISK=#{img} disk"
      expect(File.writable?(img)).to be(true)
    end
  end
end
