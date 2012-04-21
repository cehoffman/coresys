module Coresys
  class Formula
    class << self
      def inherited(klass)
        (@subclasses ||= {})[klass.name.split('::').last.downcase] = klass
      end

      def find(formula)
        require Coresys.formula + "#{formula}.rb"
        @subclasses[formula.camelcase.downcase].tap do |f|
          f.file_name = formula.downcase
        end
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
        @version || url[/((?:\d+\.?)+)\.(\w+\.?)+$/, 1] ||
          (url_opts && url_opts.fetch(:tag))
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

    delegate :url, :url_opts, :version, :digest

    def name
      self.class.file_name
    end

    def etc; Coresys.base + 'etc' end
    def var; Coresys.base + 'var' end

    def prefix; Coresys.cellar + name + version end
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
