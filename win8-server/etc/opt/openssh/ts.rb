#!/usr/bin/ruby -W
# frozen_string_literal: true

require "time"

$stdout.sync = true
ARGF.each { |l| print "#{Time.now.iso8601(9)} #{l}" }
