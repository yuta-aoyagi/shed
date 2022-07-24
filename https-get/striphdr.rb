#!/usr/bin/ruby -W
# frozen_string_literal: true

LFCRLF = [10, 13, 10].freeze

def do_work(input, output)
  a = input.each_byte.to_a
  raise unless (i = a.each_cons(3).find_index(LFCRLF))

  output << a[(i + 3)..-1].pack("C*")
end

do_work ARGF, $stdout if $PROGRAM_NAME == __FILE__
