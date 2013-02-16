url = ARGV[0]
name = url.split('/')[-1][/([a-zA-Z\-_]+)/, 1].gsub(/[-_]([a-zA-Z])?/) { |cap| cap.upcase if cap }
name.rstrip!('-_')

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

ARGV[0] = name
require_relative 'edit'
