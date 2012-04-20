require 'coresys/version'
require 'fileutils'
require 'core_ext'

module Coresys
  autoload :DownloadStrategy, 'coresys/download_strategy'
  autoload :Formula, 'coresys/formula'
  autoload :Installer, 'coresys/installer'
  autoload :Linker, 'coresys/linker'

  class << self
    def install(name)
      formula = Formula.find(name).new
      Installer.new(formula).install
      link(formula)
    end

    def link(name)
      formula = name.is_a?(Formula) && name || Formula.find(name).new
      Linker.new(formula).link
    end

    def unlink(name)
      Linker.new(Formula.find(name).new).unlink
    end

    def base
      Pathname.new(ENV['HOME']) + '.local'
    end

    def cellar
      Pathname.new(ENV['HOME']) + '.local/cellar'
    end

    def formula
      data + 'formula'
    end

    def data
      Pathname.new(ENV['HOME']) + '.coresys'
    end

    def linked
      data + 'linked'
    end

    def linked!
      linked.tap { |f| f.mkpath unless f.directory? }
    end

    def tmp
      data + 'tmp'
    end

    def tmp!
      tmp.tap { |f| f.mkpath unless f.directory? }
    end

    def cache
      data + 'cache'
    end

    def cache!
      cache.tap { |f| f.mkpath unless f.directory? }
    end
  end
end
