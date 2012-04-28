module Kernel
  @@level = -1

  def level_pointer
    return '==>' if @@level < 0
    (' ' * @@level) + ('=' * (2 - @@level)) + '>'
  end

  def section_start(*args)
    @@level += 1
    section(*args)
  end

  def section_end(*args)
    args = ['', {level: false, newline: false}] if args.empty?
    section(*args)
    @@level -= 1
  end

  def opt_line(line, options)
    line = "#{Tty.send(options.fetch(:text, 'none'))}#{line}#{Tty.reset}"
    line = "#{Tty.send(options[:level])}#{level_pointer}#{Tty.reset} #{line}" if options.fetch(:level, false)
    line = line + $/ if options.fetch(:newline, true)
    print line
  end

  def section(name, options = {})
    opt_line name, {level: 'green', text: 'white'}.merge(options)
  end

  def info(msg, options = {})
    opt_line msg, {level: 'blue'}.merge(options)
  end

  def warn(msg, newline = $/)
    opt_line "#{Tty.red}Warning#{Tty.reset}: #{msg}", {level: 'red'}.merge(options)
  end

  def error(msg)
    lines = msg.split $/
    puts "#{Tty.red}Error#{Tty.reset}: #{lines.shift}"
    puts lines unless lines.empty?
  end

  def error!(msg)
    error(msg)
    exit 1
  end

  def columned(title, items)
    section title
    IO.popen(['column', '-c', Tty.width.to_s], 'w') { |io| io.puts items }
  end

  # This impementation of system aborts on failure
  # and does not swallow ^C to allow for graceful exit
  def safe_system(cmd, *args)
    args.map!(&:to_s)
    Process.waitpid(fork do
      yield if block_given?
      # Only raises SystemCallError on execution error and
      # Errno::ENOENT (typically) if the command can't be found
      exec cmd, *args rescue nil
      exit! 1
    end)

    unless $?.success?
      args.map! { |arg| arg.gsub(' ', "\\ ")}
      error!("Running #{cmd} #{args}")
    end
  end

  def captured_system(*args)
    rd, wr = IO.pipe
    safe_system(*args) do
      $stdout.reopen wr
      $stderr.reopen wr
    end
    wr.close
    rd.read
  end

  def silent_system(*args)
    safe_system(*args) do
      $stdout.reopen('/dev/null')
      $stderr.reopen('/dev/null')
    end
  end
end

# This was taken from Homebrew directly
module Tty extend self
  def blue; bold 34; end
  def white; bold 39; end
  def red; underline 31; end
  def yellow; underline 33 ; end
  def reset; escape 0; end
  def em; underline 39; end
  def green; color 83 end
  def none; '' end

  def width
    @width ||= %x[stty size].split.last.to_i
  end

  private
  def color n
    escape "0;#{n}"
  end
  def bold n
    escape "1;#{n}"
  end
  def underline n
    escape "4;#{n}"
  end
  def escape n
    "\033[#{n}m" if $stdout.tty?
  end
end
