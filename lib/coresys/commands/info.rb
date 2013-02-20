formula = Coresys::Formula.find(ARGV[0]).new
puts "#{formula.name} #{formula.version}"
puts formula.homepage if formula.homepage

if formula.installed?
  print "Available Versions: "
  active = formula.linked? && (Coresys.linked + formula.name).realpath.basename || formula.version
  formula.root.children.each do |entry|
    next unless entry.directory?
    output = entry.basename
    output = "#{Tty.green}#{output}*#{Tty.reset}" if entry.basename == active
    print output, ' '
  end
  puts
end

if formula.linked?
  linked = (Coresys.linked + formula.name).realpath
  puts "#{linked} (#{linked.summary})"
end

section_start "Options"
formula.class.options.each do |k, v|
  puts "--with-#{k}", "\t#{v}"
end
