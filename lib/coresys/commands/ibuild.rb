formula = Coresys::Formula.find(ARGV[0])
Coresys::Installer.new(formula).install do
  system(ENV['SHELL'], '-l')
  raise StandardError, "Interactive build canceled" unless $/.success?
end
Coresys.link(ARGV[0])
