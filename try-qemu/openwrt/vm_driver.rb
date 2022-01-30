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

ACCEPTED = "accepted".freeze

def create_logger(err_out)
  Logger.new err_out
end

def recv_thread(sock, logger, kernel)
  while !sock.closed? && !sock.eof?
    kernel.sleep 0.1
    s = sock.readpartial(1024).inspect.gsub '\n', "\n"
    logger.debug s
  end
end

def do_work(vm_driver, port, err_out, kernel)
  l = create_logger err_out
  l.info "start"
  vm_driver.srv = srv = TCPServer.new "127.0.0.1", port
  s = srv.accept
  l.info ACCEPTED
  th = Thread.new { recv_thread s, l, kernel }
  vm_driver.todo = { :l => l, :s => s, :th => th }

  IRB.start __FILE__

  l.info "quit"
end

do_work VMDriver, 4444, $stderr, Kernel if $PROGRAM_NAME == __FILE__
