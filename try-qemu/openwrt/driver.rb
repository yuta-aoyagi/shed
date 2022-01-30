#!/usr/bin/ruby -W

require "English"
require "socket"

module Driver # TODO: find a unique name
  class <<self
    attr_accessor :srv, :todo
  end
end

def do_work(driver, port)
  driver.srv = TCPServer.new "::1", port

  require "irb"
  IRB.start __FILE__
end

do_work Driver, 4444 if $PROGRAM_NAME == __FILE__
