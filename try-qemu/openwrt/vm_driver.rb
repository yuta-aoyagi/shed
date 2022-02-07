#!/usr/bin/ruby -W

require "English"
require "expect"
require "irb"
require "logger"
require "socket"
require "time"

class VMDriver
  class <<self
    attr_accessor :srv, :todo
  end
end

# The highlighted entry will be executed automatically in 5s. <- GRUB
# "Press the [f] key and hit [enter] to enter failsafe mode\r\nPress the [1], [2], [3] or [4] key and hit [enter] to select the debug level\r\n" <- /lib/preinit/30_failsafe_wait
# Please press Enter to activate this console.\r\n <- Busybox init askfirst
# (net device `link becomes ready`?)
# "\r\nroot@OpenWrt:/# "

# network.lan=interface\r\nnetwork.lan.device='br-lan'\r\nnetwork.lan.proto='static'\r\nnetwork.lan.ipaddr='192.168.1.1'\r\nnetwork.lan.netmask='255.255.255.0'\r\nnetwork.lan.ip6assign='60'\r\n

ACCEPTED = "accepted".freeze

class LogFormatter
  def initialize
    @base = nil
  end

  def call(severity, time, progname, msg)
    time_str = time.dup.utc.iso8601 9
    @base = time if !@base && msg == ACCEPTED
    diff = @base ? (time - @base).to_s : "N/A"
    msg_str = msg.is_a?(String) ? msg : msg.inspect
    "[%s (%s) #%d] %5s: %s\n" % [time_str, diff, $$, severity, msg_str]
  end
end

def create_logger(err_out)
  l = Logger.new err_out
  l.formatter = LogFormatter.new
  l
end

def recv_thread(sock, logger, kernel)
  logger.info sock.expect(/press enter to activate this console/i, 120)
  while !sock.closed? && !sock.eof?
    kernel.sleep 0.1
    s = sock.readpartial(1024).inspect.gsub('\t', "\t").gsub '\n', "\n"
    logger.debug s
  end
  sock.close
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
