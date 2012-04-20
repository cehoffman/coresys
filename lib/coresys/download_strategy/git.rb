module Coresys
  module DownloadStrategy
    class Git < Abstract
      def fetch
        info "Cloning #{@formula.url}"
        if cached_path.exist?
          cached_path.rmtree unless Dir.chdir(cached_path) { silent_system('git', 'status', '-s') }
        end

        if !cached_path.exist?
          safe_system 'git', 'clone', @formula.url, cached_path
        else
          puts "Updating #{cached_path}"
          Dir.chdir(cached_path) do
            safe_system 'git', 'remote', 'set-url', 'origin', @formula.url
            silent_system 'git', 'fetch', 'origin'
            silent_system 'git', 'fetch', '--tags'
          end
        end
      end

      def stage
        origin = Dir.getwd
        Dir.chdir cached_path

        @spec, @ref = @formula.url_opts && @formula.url_opts.first
        if @spec && @ref
          info "Checking out #@spec #@ref"
          case @spec
          when :branch then silent_system 'git', 'checkout', "origin/#@ref"
          when :tag, :sha then silent_system 'git', 'checkout', @ref
          end
        else
          safe_system 'git', 'reset', '--hard', 'origin/HEAD' 
        end

        safe_system 'git', 'checkout-index', '-a', '-f', "--prefix=#{origin}/"
        if File.exists?('.gitmodules');
          safe_system 'git', 'submodule', 'init'
          safe_system 'git', 'submodule', 'update'
          safe_system 'git', 'submodule', '--quiet', 'foreach', '--recursive', 'git', 'checkout-index', '-a', '-f', "--prefix=#{origin}/$path/"
        end

        ENV['GIT_DIR'] = cached_path + '.git'
      ensure
        Dir.chdir origin
      end
    end
  end
end
