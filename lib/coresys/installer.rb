module Coresys
  class Installer
    def initialize(formula)
      @formula = formula
      @downloader = DownloadStrategy.guess(formula)

      if @formula.installed?
        if @formula.exact_version_installed? && ARGV.include?('--force')
          @formula.prefix.rmtree
        else
          error!("#{@formula.name}@#{(Coresys.linked + @formula.name).realpath.basename} already installed")
        end
      end
    end

    def patch
    end

    def install
      @downloader.fetch
      @downloader.verify

      mktemp do
        @downloader.stage
        patch

        oENV = ENV.to_hash
        begin
          block_given? && yield || @formula.install
        rescue Exception
          @formula.prefix.rmtree if @formula.prefix.exist?
          raise
        ensure
          ENV.replace oENV
        end
      end

      link
    rescue Interrupt => e
      puts
      info 'Got interrupt'
    end

    def mktemp
      dir = %x[mktemp --tmpdir="#{Coresys.tmp!}" -d coresys-#{@downloader.unique_name}-XXXXX].strip
      error! 'Could not create sandbox' unless $?.success? && File.directory?(dir)
      origin = Dir.pwd
      begin
        Dir.chdir dir
        yield
      ensure
        FileUtils.rm_rf dir, secure: true if File.directory?(dir) 
        Dir.chdir origin
      end
    end

    def link
      Linker.new(@formula.name, @formula.version, @formula.prefix).link
    end
  end
end
