#!/usr/bin/env ruby

require 'coresys'

outdated = Coresys.cellar.children.select do |entry|
  formula = Coresys::Formula.find_or_stub(entry.basename)
  entry.children.map(&:basename).any? { |f| f == formula.version }
end.map(&:basename)

if outdated.size > 0
  columned "Outdated formula", outdated
else
  puts "No outdated formula"
end
