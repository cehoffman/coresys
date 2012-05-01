# commands: list all the available commands with a short description

cmd = /^coresys-(.+)|#{File.join(File.dirname(__FILE__), '')}(.+)\.rb/
cmds = []

(ENV['PATH'].split(File::PATH_SEPARATOR) << File.dirname(__FILE__)).each do |path|
  (Dir.entries(path) - ['.', '..']).each do |item|
    next unless item =~ cmd
    cmds << [$1]

    head = open(File.join(path, item)) { |io| io.readlines(5) }.join
    cmds.last << $1 if head =~ /^#[^!]#{$1}: (.*)$/
  end if Dir.exists?(path)
end

length = cmds.map(&:first).sort_by(&:length).last.length
cmds.sort_by(&:first).each do |cmd, desc|
  puts "#{cmd.ljust(length + 5)}#{desc}"
end
