#!/usr/bin/ruby -W
# frozen_string_literal: true

require "English"
require "expect"
require "irb"
require "logger"
require "socket"
require "time"

# Holds some instance variables instead of global variables.
class VMDriver
  class << self
    attr_accessor :srv, :todo
  end
end

# The highlighted entry will be executed automatically in 5s. <- GRUB
# "Press the [f] key and hit [enter] to enter failsafe mode\r\n
# Press the [1], [2], [3] or [4] key and hit [enter] to select the debug level\r\n"
# <- /lib/preinit/30_failsafe_wait
# Please press Enter to activate this console.\r\n <- Busybox init askfirst
# (net device `link becomes ready`?)
# "\r\nroot@OpenWrt:/# "

# network.lan=interface\r\nnetwork.lan.device='br-lan'\r\nnetwork.lan.proto='static'\r\n
# network.lan.ipaddr='192.168.1.1'\r\nnetwork.lan.netmask='255.255.255.0'\r\nnetwork.lan.ip6assign='60'\r\n

ACCEPTED = "accepted".freeze # rubocop:disable Style/RedundantFreeze

# Formats log lines with the time elapsed from the moment ACCEPTED comes.
class LogFormatter
  def initialize
    @base = nil
  end

  def call(severity, time, _progname, msg)
    time_str = time.dup.utc.iso8601 9
    @base = time.dup if !@base && msg == ACCEPTED
    diff = @base ? (time - @base).to_s : "N/A"
    msg_str = msg.is_a?(String) ? msg : msg.inspect
    svr = format "%5s", severity
    "[#{time_str} (#{diff}) ##{$PID}] #{svr}: #{msg_str}\n"
  end
end

# Dumps the specified IO's content to a logger.
module IODumper
  module_function

  def dump(io, logger, prefix, kernel)
    while !io.closed? && !io.eof?
      kernel.sleep 0.1
      s = io.readpartial(1024).inspect.gsub('\t', "\t").gsub '\n', "\n"
      logger.debug "#{prefix}#{s}"
    end
  ensure
    io.close
  end
end

# Installs dockerd.
module DockerdInstaller
  ADJUST_FIREWALL = <<-SHELL.gsub(/^    /, "").freeze
    date && opkg info firewall4 | grep -q " installed" && date &&
      opkg remove luci-ssl luci luci-app-firewall firewall4 && date &&
      opkg install firewall
  SHELL

  module_function

  def call
    yield(ADJUST_FIREWALL, 200) &&
      yield("opkg install dockerd\n", 870)
  end
end

SSH_SETUP_COMMAND = <<SHELL.gsub(/^  /, "").freeze
  rm /etc/dropbear/dropbear_*_host_key &&
    wget -P /etc/init.d http://10.0.2.2:40080/hostkey &&
    chmod +x /etc/init.d/hostkey && $_ enable
SHELL

# Handles the VM's serial output.
class RxThread
  def self.start(sock, logger, kernel)
    Thread.new { new(sock, logger, kernel).call }
  end

  def initialize(sock, logger, kernel)
    @sock = sock
    @logger = logger
    @kernel = kernel
  end

  def call
    expect_fully_booted(40) && ifup && expand_rootfs &&
      expect_fully_booted(390) && install_docker && setup_ssh && ok_to_finish
    dump_rest
    final_cleanup_if_ok
  ensure
    @logger.info "rx finished"
  end

  private

  # assuming that link always becomes ready enough after consoles start
  # waiting for enter key.
  def expect_fully_booted(timeout)
    expect_kernel_loaded(timeout) &&
      my_expect(/press enter to activate this console.{1,4}\n/i, 90) &&
      expect_link_ready(90) &&
      activate_console
  end

  def expect_kernel_loaded(timeout)
    my_expect(/the highlighted entry will be [a-z]+ automatically/i, 40) &&
      my_expect(/^\[ *\d+\.\d+\]/, timeout) &&
      my_expect(/linux version \d+\.\d+/i, 1)
  end

  def activate_console
    send_and_wait "\n", 10
  end

  def ifup
    empty = ""
    sh = File.open("ifup.sh") { |f| f.grep(/^[^\n#]/).join(empty) }
    send_and_wait(sh, 30) &&
      expect_link_ready(120)
  end

  LINK_READY = "br-lan: link becomes ready"
  LINK_READY.freeze

  def expect_link_ready(timeout)
    my_expect LINK_READY, timeout
  end

  ER = <<-'SHELL'.gsub(/^    /, "").freeze
    f() { wget -P ~ http://10.0.2.2:40080/expand-rootfs.sh; } &&
      f || { sleep 3 && f; } &&
      sh -eu -x ~/expand-rootfs.sh \
        sh -c 'opkg install tune2fs && tune2fs -j "$ROOT"'
  SHELL

  def expand_rootfs
    @sock << ER
    [30, 220, 170].each { |n| return nil unless my_expect(/^\+ /, n) }
    my_expect(/^Installing tune2fs \([-.0-9]+\) to .+\.\.\./, 40) &&
      my_expect(/^tune2fs \d+\.\d+/, 30) &&
      my_expect("was not cleanly unmounted", 6) &&
      my_expect(" machine restart", 70)
  end

  def install_docker
    return nil unless send_and_wait "opkg update\n", 220

    @sock << "opkg install runc\n"
    my_expect(/^Configuring runc/, 150) && expect_prompt(2) &&
      send_and_wait("opkg install containerd\n", 980) &&
      DockerdInstaller.call(&method(:send_and_wait)) &&
      send_and_wait("opkg install docker\n", 310)
  end

  def setup_ssh
    send_and_wait SSH_SETUP_COMMAND, 4
  end

  def send_and_wait(buf, timeout)
    @sock << buf
    expect_prompt timeout
  end

  def expect_prompt(timeout)
    my_expect %r{^root@[A-Za-z]+:/# }, timeout
  end

  def my_expect(pat, timeout)
    @logger.info(x = @sock.expect(pat, timeout))
    x
  end

  def dump_rest
    IODumper.dump @sock, @logger, "", @kernel
  end

  def ok_to_finish
    @ok = !(@sock << "sync && sync && sync && poweroff\n").nil?
  end

  def final_cleanup_if_ok
    return unless @ok

    @kernel.sleep 1 # ideally, Thread#join on the VM thread
    t = Thread.current
    (a = t.group.list - [t]).size == 1 && a.first.exit
  end
end

def create_logger(err_out)
  l = Logger.new err_out
  l.formatter = LogFormatter.new
  l
end

def start_vm_thread(logger, kernel)
  Thread.new do
    IO.popen "make run2 2>&1", "r+" do |io|
      Thread.current[:io] = io
      IODumper.dump io, logger, "vm ", kernel
    end
  end
end

def do_work(vm_driver, port, err_out, kernel)
  l = create_logger err_out
  l.info "start"
  vm_driver.srv = srv = TCPServer.new "127.0.0.1", port
  vm_th = start_vm_thread l, kernel
  s = srv.accept
  l.info ACCEPTED
  th = RxThread.start s, l, kernel
  vm_driver.todo = { :l => l, :s => s, :th => th, :vm_th => vm_th }

  IRB.start __FILE__

  l.info "quit"
end

do_work VMDriver, 4444, $stderr, Kernel if $PROGRAM_NAME == __FILE__
