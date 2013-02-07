require 'find'

module Coresys
  class Linker
    PATHS = ['etc', 'bin', 'sbin', 'include', 'share', 'lib']

    def initialize(name, version, prefix)
      @name, @version, @prefix = name, version, prefix
    end

    def tag
      "#@name@#@version"
    end

    def record
      @record ||= Coresys.linked! + @name
    end

    def linked?
      record.symlink? && record.readlink == @prefix
    end

    def link
      error!("#@name@#@version already linked") if linked?

      info("Linking #{tag}... ", newline: false)
      count = PATHS.map { |path| link_path(path) }.sum
      info "created #{count} symlink#{'s' if count > 1}", level: false
      record.unlink if record.exist?
      File.symlink(@prefix, record)
    end

    def unlink
      info "Unlinking #{tag}... ", newline: false
      count = PATHS.map { |path| unlink_path(path) }.sum
      info "removed #{count} symlink#{'s' if count > 1}", level: false
      record.unlink if record.exist?
    end

    def link_path(source)
      source = @prefix + source
      return 0 unless source.exist?

      count = 0
      (Coresys.base + source.basename).mkpath
      Find.find(source) do |path|
        next if path == source
        path = Pathname.new(path)
        partial_path = path.relative_path_from(@prefix)
        dest = Coresys.base + partial_path

        if File.file?(path) && path.basename != '.DS_Store'
          if dest.exist?
            symlink = path.relative_path_from(dest.parent)
            error!("Will not overwrite staged file #{dest}") if dest.readlink != symlink
          else
            File.symlink(path.relative_path_from(dest.parent), dest)
            count += 1
          end
        elsif File.directory?(path)
          dest.mkpath unless dest.exist?
        else
          puts "Got unknown #{path}"
        end
      end

      count
    end

    def unlink_path(source)
      source = @prefix + source
      return 0 unless source.exist?

      count = 0
      Find.find(source) do |path|
        next if path == source
        path = Pathname.new(path)
        partial_path = path.relative_path_from(@prefix)
        dest = Coresys.base + partial_path

        # Skip if dest isn't there
        next unless dest.exist?

        # Unlink when it is a symlink we created
        count += 1 && dest.unlink if dest.symlink?

        # In preparation for walking up the tree to detect empty
        # directories add a path compoenent that will be striped
        # immediately in the directory case
        dest = dest + 'a' if dest.directory?

        begin
          dest = dest.parent
          dest.rmdir if dest.children.empty?
        end until dest == Coresys.base
      end

      count
    end
  end
end
