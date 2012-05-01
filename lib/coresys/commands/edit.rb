formula = Coresys::Formula.find(ARGV[0])
error!("EDITOR environment variable is not set") unless ENV['EDITOR']
file = (Coresys.formula + formula.file_name).to_s + '.rb'
exec ENV['SHELL'], '-c', ENV['EDITOR'] + ' "$@"', '--', file
