require 'openssl'

module Coresys
  module DownloadStrategy
    class Archive < Abstract
      def verify
        type, sum = @formula.digest
        digest = OpenSSL::Digest.const_get((type ||= :sha1).upcase).new
        open(cached_path, 'rb') { |file| digest << file.read(1024) until file.eof? }
        if sum
          error! "download does not match checksum: Expected #{sum} got #{digest}" if digest != sum
        else
          info "For reference the SHA1 is #{digest}"
        end
      end

      def unique_name
        super + '-' + @formula.version
      end
    end
  end
end
