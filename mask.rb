#!/usr/bin/ruby -W

def stars(num)
  "*" * num
end

def convert_id_if_possible(line)
  return nil unless (md = /aws_access_key_id\s*=\s*/.match(line))
  (md2 = /\A(A3T|A[A-Z]{2}A|A[A-Z]ID)([0-9A-Z]{7,})/.match(md.post_match)) ||
    raise("Invalid access key ID")
  len = md2.end 0
  raise "Wrong length of access key ID" if len != 11 && !(16..128).member?(len)
  tail = md2[2]
  converted = md2[1] + stars(tail.size - 4) + tail[-4, 4]
  md.pre_match + md[0] + converted + md2.post_match
end

def convert_line(line)
  if (md = /aws_secret_access_key\s*=\s*/.match(line))
    (md2 = %r(\A[0-9A-Za-z+/=]{40}).match(md.post_match)) ||
      raise("Invalid secret access key")
    return md.pre_match + md[0] + stars(40) + md2.post_match
  end
  convert_id_if_possible(line) || line
end

def do_work(input, output)
  input.each { |l| output.print convert_line(l) }
end

do_work ARGF, $stdout if $PROGRAM_NAME == __FILE__
