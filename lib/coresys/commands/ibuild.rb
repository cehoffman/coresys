formula = Coresys::Formula.find(ARGV[0]).new
Coresys::Installer.new(formula).install do
  Dir.chdir(Dir.pwd)
  puts Dir.pwd
  system(ENV['SHELL'], '-l')
  raise StandardError, "Interactive build canceled" unless $?.success?
end
Coresys.link(ARGV[0])
