module Coresys
  class Installer
    def initialize(formula)
      @formula = formula
      @downloader = DownloadStrategy.guess(formula)

      if @formula.prefix.exist?
        if ARGV.include?('--force')
          @formula.prefix.rmtree
        else
          error!("#{@formula.name}@#{@formula.version} already installed")
        end
      end
    end

    def patch
    end

    def install
      start = Time.now
      section_start "Installing #{@formula.name}@#{@formula.version}"
      @downloader.fetch
      @downloader.verify

      mktemp do
        @downloader.stage
        patch

        oENV = ENV.to_hash
        begin
          block_given? && yield || @formula.install
        rescue Exception
          (puts Dir.pwd; system ENV['SHELL']) if ARGV.include?('--interactive')
          @formula.prefix.rmtree if @formula.prefix.exist?
          raise
        ensure
          ENV.replace oENV
        end
      end

      duration = Time.now - start
      type = ['seconds', 'minutes', 'hours'].detect { (duration /= 60) < 1 }
      summary = @formula.prefix.exist? && @formula.prefix.summary + ', ' || ''
      section_end "Installed #{@formula.name}@#{@formula.version}: #{@summary}built in %0.1f #{type}" % [duration * 60]
    rescue Interrupt => e
      puts
      info 'Aborting install'
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
  end
end
