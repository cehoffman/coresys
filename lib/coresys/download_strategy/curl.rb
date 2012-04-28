module Coresys
  module DownloadStrategy
    class Curl < Archive
      def fetch
        info "Downloading #{@formula.url}"
        return info("Already downloaded: #{cached_path}") if File.exists?(cached_path)
        system 'curl', @formula.url, '--progress-bar', '-Lo', cached_path
      end

      def stage
        sig = open(cached_path, 'rb') { |f| f.read(6) }

        case sig
        when /^PK\003\004/ # zip
          safe_system 'unzip', '-qq', cached_path
        when /^\037\213/, /^BZh/, /^\037\235/ # gzip, bz2, compress
          safe_system 'tar', 'xf', cached_path
        when /^\xFD7zXZ\x00/ # xz
          safe_system %|xz -dc "#{cached_path}" \| tar xf -|
        when 'Rar!'
          safe_system 'unrar', 'x', '-inul', cached_path
        else
          raise ArgumentError, 'unknown archive type for curl download'
        end

        dirs = Dir['*'].select { |f| File.directory?(f) }
        error! 'Empty archive' if dirs.empty?
        Dir.chdir dirs.first
      end
    end
  end
end
