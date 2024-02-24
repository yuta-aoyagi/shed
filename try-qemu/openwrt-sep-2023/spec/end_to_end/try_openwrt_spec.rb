# frozen_string_literal: true

require "tempfile"

RSpec.describe "try_openwrt's Makefile" do
  it "has a target `help`" do
    pending
    Tempfile.open("", ".") do |err|
      err.close
      output = `make help 2>#{err.path}`
      expect(output).to match(/[Uu]sage: (.* )?make /)
    end
  end
end
