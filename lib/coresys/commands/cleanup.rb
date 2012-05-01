Coresys.cellar.children.each do |entry|
  next unless entry.directory?
  Coresys.cleanup(entry.basename)
end

# Only cleanup cache when this is a general cleanup
Coresys.cache.children.each do |entry|
  entry.unlink if entry.file?
end if ARGV.empty?
