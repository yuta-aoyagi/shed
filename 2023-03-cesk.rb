#!/usr/bin/ruby -W
# frozen_string_literal: true

require "pp"

def niy
  raise "Not implemented yet"
end

def fv(term)
  if term.is_a? Symbol
    [term]
  elsif term.first == :lambda
    fv(term[2]) - [term[1]]
  elsif term.size == 2
    fv(term.first).union fv(term.last)
  else
    raise "Bad term #{term}"
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

# apply a partial function func to arg
# or nil if arg isn't in func's domain
def apply(func, arg)
  it = func
  it = it.first while it && it[1] != arg
  it ? it.last : nil
end

def cesk(control, env, store, kont)
  if control == :daggar
    raise "expected empty E, but was #{env}" if env
    raise "expected ret-k, but was #{kont}" if kont[1] != :ret

    if kont.first == :stop
      clo = kont[2]
      raise "BUG invalid value #{clo}" unless valid_clo?(clo)

      nil
    elsif kont.first[1] == :arg
      [kont.first[2], kont.first[3], store, [kont.first.first, :fun, kont.last]]
    elsif kont.first[1] == :fun
      clo = kont.first[2]
      v = kont.last
      abs, rho = clo
      _, x, m = abs
      case abs.first
      when :lambda
        n = $num ||= 0 # FIXME
        $num += 1
        [m, [rho, x, n], [store, n, v], kont.first.first]
      else
        niy
      end
    else
      niy
    end
  elsif control.is_a? Symbol
    x = control
    raise "undefined variable #{x} in #{env}" unless (n = apply env, x)
    raise "BUG unbound store #{n} in #{store}" unless (clo = apply store, n)

    [:daggar, nil, store, [kont, :ret, clo]]
  elsif control.first == :lambda
    [:daggar, nil, store, [kont, :ret, [control, env]]]
  elsif control.size == 2 # application
    [control.first, env, store, [kont, :arg, control.last, env]]
  else
    niy
  end
end

def eval_cesk(term)
  c = term
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
def try_limited(term, max)
  n = max - 1
  ret = eval_cesk(term).with_index do |(c, e, s, k), i|
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
