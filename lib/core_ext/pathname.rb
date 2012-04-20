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
end
