require 'pathname'

class Pathname
  alias :to_str :to_s

  def install(*files)
    files.flatten.map do |file|
      if Hash === file
        file.map do |source, new_name|
          install_p source, new_name
        end
      else
        install_p file
      end
    end.flatten
  end

  def install_p(source, new_name = nil)
    dest = self + File.basename(new_name || source)
    error!("#{source} does not exists for install ") unless File.exists?(source)
    mkpath
    safe_system 'mv', source, dest
    dest
  end

  def summary
    size, files, dirs = [0] * 3

    find do |f|
      size += f.size
      files += 1 if f.file?
      dirs += 1 if f.directory?
    end

    type = ['B', 'K', 'M', 'G', 'T'].detect { (size /= 1024.0) < 1 }

    "#{files} files, #{dirs} dirs, %.2f#{type}" % [size * 1024]
  end

  def abrev
    to_s.sub(ENV['HOME'], '~')
  end
end
