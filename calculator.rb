#!/usr/bin/env ruby
def calc(line)
  if (!valid?(line))
    "Please ensure your parentheses match."
  else
    parse(tokenize(line))
  end
end

def eval(tokens)
  comparators = {'>' => :>, '>=' => :>=, '<' => :<, '<=' => :<=, '==' => :==}
  symbols = {
    '+' => lambda{|x| x.inject(0){|sum,x| sum + x}},
    '-' => lambda{|x| x[1..x.length - 1].inject(x[0]){|diff,x| diff - x}},
    '*' => lambda{|x| x.inject(1){|prod,x| prod * x}},
    '/' => lambda{|x| x[1..x.length-1].inject(x[0]){|divisor,x| divisor / x}},
    'car' => lambda{|x| x[0]},
    'cdr' => lambda{|x| x[1..x.length]}
  }
  comparators.each do |k,v|
    symbols[k] = lambda{|x| x.first.send(v,x[1])}
  end
  begin
    tokens.to_i
  rescue NoMethodError
    if (symbols.keys.include? tokens.first)
      args = tokens[1..tokens.length].map{|token| eval(token)}
      if (args)
        symbols[tokens[0]].call args
      end
    elsif (tokens.first == 'if')
      tokens.shift
      condition, consequence, alt = tokens
      eval(condition) ? eval(consequence) : eval(alt)
    else
      tokens.map{|x| eval(x)}
    end
  end
end

def repl
  while (true)
    print 'rcalc> '
    puts eval(parse(tokenize(gets))).to_s
  end
end

""" Ensures that parentheses are balanced """
def valid?(line)
  valid_helper(line, 0, line.length/2)
end

def valid_helper(line, count, ceiling)
  if (line.length == 0)
    count == 0
  elsif (count > ceiling)
    false
  elsif (line[0] == '(')
    valid_helper(line[1..line.length], count + 1, ceiling)
  elsif (line[0] == ')')
    valid_helper(line[1..line.length], count - 1, ceiling)
  else
    valid_helper(line[1..line.length], count, ceiling)
  end
end

""" Assumes valid line (namely, valid parenthetical matching) and returns tokens """
def tokenize(line)
  line.gsub('(', ' ( ').gsub(')', ' ) ').split(" ")
end

def parse(line)
  rtn = parse_helper(line, [])
  rtn.nil? ? [] : rtn
end

def parse_helper(line, so_far)
  if (line.length == 0)
    so_far
  elsif (line[0] == '(' or line[0] == ')')
    line.shift
    parse_helper(line, so_far)
  else
    rtn = []
    curr = 0
    while (line[curr] != ')' and line[curr] != '(')
      rtn << line[curr]
      curr += 1
    end
    if (so_far.length > 0)
      so_far << rtn
    else
      so_far = rtn
    end
    line.shift curr
    parse_helper(line, so_far).compact
  end
end

repl