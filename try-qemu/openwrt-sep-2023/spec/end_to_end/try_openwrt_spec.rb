# frozen_string_literal: true

require "tempfile"

RSpec.describe "try_openwrt's Makefile" do
  it "has a target `help`" do
    pending
    Tempfile.open("", ".") do |out|
      out.close
      Tempfile.open("", ".") do |err|
        err.close
        system "make help >#{out.path} 2>#{err.path}"
        stderr = err.open.read
        expect(stderr).to match(/usage.*make/)
      end
    end
  end
end
