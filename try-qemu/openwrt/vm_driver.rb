#!/usr/bin/ruby -W

require "English"
require "socket"

module VMDriver
  class <<self
    attr_accessor :srv, :todo
  end
end

def do_work(vm_driver, port)
  vm_driver.srv = TCPServer.new "::1", port

  require "irb"
  IRB.start __FILE__
end

do_work VMDriver, 4444 if $PROGRAM_NAME == __FILE__
