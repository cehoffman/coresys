url = ARGV[0]
name = url[/([^\/.]+)(\..+|$)?/, 1]

(Coresys.formula + "#{name.downcase}.rb").open('wb') do |f|
  f.write <<-EOF
class #{name.capitalize} < Coresys::Formula
  url '#{url}'
  # digest :sha1, ''

  def install
    system 'make', 'install'
  end
end
EOF
end
