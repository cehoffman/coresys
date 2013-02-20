formula = Coresys::Formula.find(ARGV[0]).new
Coresys::Installer.new(formula).install do
  files = Dir.entries('.') - ['.', '..']

  # Create two identical directories and place the user in the second directory
  # to make changes which the diff will be based on
  Dir.mkdir 'a'
  safe_system 'cp', '-Rap', *files, 'a/'

  Dir.mkdir 'b'
  silent_system 'mv', *files, 'b/'

  Dir.chdir 'b' do
    info Dir.pwd

    system(ENV['SHELL'], '-l')
    unless $?.success?
      raise Corsys::Installer::AbortInstall, 'Interactive diff creation canceled'
    end
  end

  silent_system "diff -rupN a/ b/ > ~/#{formula.name}.diff"
  info "A diff has been generated in your home directory named #{formula.name}.diff"
end

