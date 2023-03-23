#!/usr/bin/ruby -W
# frozen_string_literal: true

require "pp"

def niy
  raise "Not implemented yet"
end

def fv(m)
  if m.is_a? Symbol
    [m]
  elsif m.first == :lambda
    fv(m[2]) - [m[1]]
  elsif m.size == 2
    fv(m.first).union fv(m.last)
  else
    raise "Bad term #{m}"
  end
end

def valid_clo?(clo)
  m, rho = clo
  dom = []
  rho1 = rho
  while rho1
    dom << rho1[1]
    rho1 = rho1.first
  end

  (fv(m) - dom).empty?
end

def cesk(c, e, s, k)
  if c == :daggar
    raise "expected empty E, but was #{e}" if e
    raise "expected ret-k, but was #{k}" if k[1] != :ret

    if k.first == :stop
      clo = k[2]
      raise "BUG invalid value #{clo}" unless valid_clo?(clo)
      nil
    elsif k.first[1] == :arg
      [k.first[2], k.first[3], s, [k.first.first, :fun, k.last]]
    elsif k.first[1] == :fun
      clo = k.first[2]
      v = k.last
      abs, rho = clo
      _, x, m = abs
      case abs.first
      when :lambda
        n = $num ||= 0 # FIXME
        $num += 1
        [m, [rho, x, n], [s, n, v], k.first.first]
      else
        niy
      end
    else
      niy
    end
  elsif c.is_a? Symbol
    x = c
    it = e
    it = it.first while it && it[1] != x
    raise "undefined variable #{x} in #{e}" unless it

    n = it.last
    it = s
    it = it.first while it && it[1] != n
    raise "BUG unbound store #{n} in #{s}" unless it

    clo = it.last
    [:daggar, nil, s, [k, :ret, clo]]
  elsif c.first == :lambda
    [:daggar, nil, s, [k, :ret, [c, e]]]
  elsif c.size == 2 # application
    [c.first, e, s, [k, :arg, c.last, e]]
  else
    niy
  end
end

def eval_cesk(m)
  c = m
  e = s = nil
  k = :stop
  Enumerator.new do |y|
    while (ret = cesk(c, e, s, k))
      c, e, s, k = *ret
      y << [c, e, s, k]
    end
    k[2]
  end
end

# max >= 1
def try_limited(m, max)
  n = max - 1
  ret = eval_cesk(m).with_index do |(c, e, s, k), i|
    pp [i, c, e, s, k]
    break :exceeded if i >= n
  end
  [:result, ret]
end

if $PROGRAM_NAME == __FILE__
  id = [:lambda, :x, :x]
  pp try_limited(id, 3)

  pp try_limited([id, id], 7)

  k = [:lambda, :x, [:lambda, :y, :y]]
  pp try_limited([k, id], 7)

  pp try_limited([[k, id], [:lambda, :z, :z]], 15)
end
