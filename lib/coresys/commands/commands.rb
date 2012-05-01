# commands: list all the available commands with a short description

cmd = /^coresys-(.+)/
cmds = {builtin: {}, external: {}}

Dir["#{File.join(File.dirname(__FILE__), '')}*.rb"].each do |cmd|
  cmds[:builtin][File.basename(cmd).sub(/\.rb$/, '')] = [cmd]
end

external = ENV['PATH'].split(File::PATH_SEPARATOR).reverse.each do |path|
  Dir["#{File.join(path, 'coresys-*')}"].each do |item|
    cmds[:external][File.basename(item).sub(/^coresys-/, '')] = [item]
  end
end

cmds.each do  |type, list|
  list.each do |name, props|
    head = open(props.first, 'r') { |io| io.readlines(5) }.join
    props  << $1 if head =~ /^#[^!]#{name}: (.*)$/
  end
end

cmds.each do |type, cmds|
  next if cmds.empty?
  length = cmds.map(&:first).sort_by(&:length).last.length
  puts "#{type.capitalize} commands"
  cmds.sort_by(&:first).each do |cmd, (path, desc)|
    puts "  #{cmd.ljust(length + 5)}#{desc}"
  end
end
