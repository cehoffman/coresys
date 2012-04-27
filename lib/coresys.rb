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

    # Uninstall removes all the installed versions of the formula
    # and unlinks the currently linked one if present
    def uninstall(name)
      formula = Formula.find_or_stub(name).new
      error!("#{formula.name} is not installed") unless formula.installed?

      if formula.linked?
        linked = (Coresys.linked + formula.name).realpath
        Linker.new(formula.name, linked.basename, linked).unlink
      end

      formula.root.children.each do |version|
        info "Removing #{formula.name}@#{version.basename}"
        version.rmtree
      end
    end

    # First verify the given forumla has been built and exists
    # in the cellar before removing all versions that are not linked.
    def cleanup(name)
      formula = Formula.find_or_stub(name).new
      error!("#{name} is not installed") unless formula.installed?

      # If the formula is not linked, pretend like the latest version
      # has been linked to prevent it from being cleaned up
      linked = Coresys.linked + formula.name
      linked = linked.exist? && linked.realpath || formula.prefix

      versions = formula.root.children

      if versions.size > 1
        versions.reject! { |version| version == linked}
        versions.each do |version|
          info "Removing #{formula.name}@#{version.basename}"
          version.rmtree
        end
      end
    end

    # Given a different version of a formula exists from the one installed
    # it will unlink the currently installed version, install the new version
    # and then remove the old versions of the formula
    def upgrade(name)
      formula = Formula.find(name).new
      error!("#{formula.name} is already at latest") if formula.exact_version_installed?

      # Unlink current version before installing
      linked = (Coresys.linked + formula.name).realpath
      Linker.new(formula.name, linked.basename, linked).unlink

      begin
        install(formula.name)
      rescue Exception => e
        # Make sure to put links back on error
        Linker.new(formula.name, linked.basename, linked).link
      end

      cleanup(formula.name)
    end

    def link(name)
      formula = Formula.find_or_stub(name).new
      error!("#{formula.name} is not installed") unless formula.installed?
      error!("#{formula.name} is already linked") if formula.exact_version_linked? && !ARGV.include?('--force')

      # By default it will automatically unlink any versions other then
      # the current most recent version. In that case it require a force
      # argument to redo the link.
      unlink(name) if formula.linked?
      Linker.new(formula.name, formula.version, formula.prefix).link
    end

    def unlink(name)
      formula = Formula.find_or_stub(name).new
      error!("#{formula.name} is not linked") unless formula.linked?
      linked = (Cellar.linked + formula.name).realpath 
      Linker.new(formula.name, linked.basename, linked).unlink
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
