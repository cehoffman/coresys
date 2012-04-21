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
      Installer.new(Formula.find(name).new).install
    end

    def uninstall(name)
      formula = Coresys::Formula.find(name).new
      error!("#{formula.name} is not installed") unless formula.installed?
      linked = (Coresys.linked + formula.name).realpath
      Linker.new(formula.name, linked.basename, linked).unlink
      info "Removing #{formula.name}@#{linked.basename}"
      linked.rmtree
    end

    def upgrade(name)
      formula = Coresys::Formula.find(name).new
      error!("#{formula.name} is already at latest") if formula.exact_version_installed?
      uninstall(formula.name)
      install(formula.name)
    end

    def link(name)
      formula = Formula.find(name).new
      Linker.new(formula.name, formula.version, formula.prefix).link
    end

    def unlink(name)
      formula = Formula.find(name).new
      Linker.new(formula.name, formula.version, formula.prefix).unlink
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
