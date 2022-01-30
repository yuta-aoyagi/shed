#!/usr/bin/ruby -W

require "English"
require "irb"
require "logger"
require "socket"

module VMDriver
  class <<self
    attr_accessor :srv, :todo
  end
end

def create_logger(err_out)
  Logger.new err_out
end

def do_work(vm_driver, port, err_out)
  l = create_logger err_out
  l.info "start"
  vm_driver.srv = TCPServer.new "::1", port

  IRB.start __FILE__

  l.info "quit"
end

do_work VMDriver, 4444, $stderr if $PROGRAM_NAME == __FILE__
