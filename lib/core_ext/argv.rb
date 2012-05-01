def ARGV.options
  @options ||= select { |arg| arg =~ /^--?/ }
end

def ARGV.nonoptions
  @nonoptions ||= self - options
end
