#!/usr/bin/ruby -W

require "English"
require "logger"
require "webrick"

class MyHandler
  def initialize(logger)
    @logger = logger
    @n = 5
  end

  def service(req, res)
    if (@n -= 1) >= 0 && (x = fetch(req))
      @logger.info x.inspect
    else
      res.status = 403
    end
  end

  private

  def fetch(req)
    x = String.new
    req.body do |chunk|
      x += chunk
      return nil if x.size >= 1024
    end
    x
  end
end

def do_work(err, signal)
  handler = MyHandler.new Logger.new(err)
  srv = WEBrick::HTTPServer.new :Port => 30080
  srv.mount_proc("/data", &handler.method(:service))
  signal.trap(:INT) { srv.shutdown }
  srv.start
end

do_work $stderr, Signal if $PROGRAM_NAME == __FILE__
