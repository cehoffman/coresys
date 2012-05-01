# list: prints out all available formula that match given search

matcher = ARGV.reject { |f| f =~ /^--?/ }.first
matcher = '/./' unless matcher
matcher = matcher[0] == ?/ ? Regexp.new(matcher[1..-2]) : /#{matcher}/

formula = Dir[Coresys.formula + '*.rb'].map do |formula|
  File.basename(formula).sub(/\.rb$/, '')
end.select do |formula|
  formula =~ matcher
end.sort

columned('Available formula', formula)
