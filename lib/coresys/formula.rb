module Coresys
  class Formula
    @subclasses = Hash.new do |h, k|
      require Coresys.formula + "#{k}.rb"
      h[k.tr('_-', '')].file_name = k
      h[k] = h[k.tr('_-', '')]
    end

    class << self
      def inherited(klass)
        @subclasses[klass.name.split('::').last.downcase] = klass
      end

      def find(formula)
        @subclasses[formula.to_s.downcase]
      rescue LoadError => e
        error!("#{formula} does not have a formula")
      end

      def find_or_stub(formula)
        file_name = formula.to_s.downcase
        @subclasses[file_name]
      rescue LoadError => e
        name = formula.to_s.camelcase.capitalize

        # Stub the formula to be the most reacently
        # installed version if there are installed versions
        version = 'NONE'
        root = Coresys.cellar + file_name
        if root.exist?
          last = root.children.sort_by(&:ctime).last
          version = last.basename if last
        end

        klass = eval <<-RUBY
          class #{name.capitalize} < Coresys::Formula
            version #{version.to_s.inspect}
            self
          end
        RUBY
        klass.file_name = file_name
        @subclasses[file_name] = klass
      end

      def devel(&block)
        instance_eval(&block) if block && ARGV.include?('--devel')
      end

      def stable(&block)
        instance_eval(&block) if block && !ARGV.include?('--devel')
      end

      def homepage(val = nil)
        return @homepage if val.nil?
        @homepage = nil
      end

      attr_accessor :file_name
      attr_reader :url_opts
      def url(val = nil, opts = nil)
        return @url if val.nil?
        @url_opts = opts
        @url = val
      end

      def version(val = nil)
        return @version = val if val
        @version ||
          (url && url[/((?:\d+\.?)+)(\.(\w+\.?)+)?$/, 1]) ||
          (url_opts && (url_opts.fetch(:tag) || url_opts.fetch(:branch) || url_opts.fetch(:sha)))
      end

      def digest(type = nil, sum = nil)
        if type.nil? && sum.nil?
          [@digest_type, @digest_sum]
        else
          @digest_type, @digest_sum = type, sum
        end
      end

      def valid?
        @url && @digest_type && @digest_sum
      end

      def delegate(*methods)
        methods.each do |method|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method}
              self.class.#{method}
            end
          RUBY
        end
      end
    end

    delegate :url, :url_opts, :version, :digest, :homepage

    def name
      self.class.file_name || self.class.name.underscore
    end

    def linked?
      (Coresys.linked + name).exist?
    end

    def exact_version_linked?
      link = Coresys.linked + name
      link.exist? && link.realpath == prefix
    end

    def installed?
      root.children.size > 0
    end

    def exact_version_installed?
      prefix.exist?
    end

    def etc; Coresys.base + 'etc' end
    def var; Coresys.base + 'var' end

    def root;    Coresys.cellar + name end
    def prefix;  root + version     end
    def bin;     prefix + 'bin'     end
    def include; prefix + 'include' end
    def lib;     prefix + 'lib'     end
    def libexec; prefix + 'libexec' end
    def sbin;    prefix + 'sbin'    end
    def share;   prefix + 'share'   end
    def doc;     share + 'doc'      end
    def info;    share + 'info'     end
    def man;     share + 'man'      end
    def man1;    man + 'man1'       end
    def man2;    man + 'man2'       end
    def man3;    man + 'man3'       end
    def man4;    man + 'man4'       end
    def man5;    man + 'man5'       end
    def man6;    man + 'man6'       end
    def man7;    man + 'man7'       end
    def man8;    man + 'man8'       end

    def system(*args)
      Kernel.info args.join(' ')
      output = ''
      IO.popen(Array(args) << {err: [:child, :out]}) do |io|
        output << io.read until io.eof?
      end

      error! "Build failed#$/#{output}" unless $?.success?
    end

    def install(&block)
      error!('block required when installing from formula') unless block
      Installer.new(self).install(&block)
    end
  end
end
