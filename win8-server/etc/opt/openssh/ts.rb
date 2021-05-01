#!/usr/bin/ruby -W

require "time"

$stdout.sync = true
ARGF.each { |l| print "#{Time.now.iso8601(9)} #{l}" }
