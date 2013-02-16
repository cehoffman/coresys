error!("EDITOR environment variable is not set") unless ENV['EDITOR']
file = Coresys.formula + "#{ARGV[0].downcase}.rb"
exec ENV['SHELL'], '-c', ENV['EDITOR'] + ' "$@"', '--', file
