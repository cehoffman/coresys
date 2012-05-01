# cat: print to screen the requested packages formula

formula = ARGV.nonoptions.first
error!('A formula must be given to cat') unless formula
formula = Coresys.formula + "#{formula}.rb"
error('Requested package does not have a formula') unless formula.exist?

puts formula.read
