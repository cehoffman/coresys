module Kernel
  def info(msg)
    puts "#{Tty.blue}==>#{Tty.white} #{msg}#{Tty.reset}"
  end

  def warn(msg)
    puts "#{Tty.red}Warrning#{Tty.reset}: #{msg}"
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

  def silent_system(*args)
    safe_system(*args) do
      $stdout.reopen('/dev/null')
      $stderr.reopen('/dev/null')
    end
  end
end

class Tty
  class <<self
    def blue; bold 34; end
    def white; bold 39; end
    def red; underline 31; end
    def yellow; underline 33 ; end
    def reset; escape 0; end
    def em; underline 39; end
    def green; color 92 end

    def width
      `/usr/bin/tput cols`.strip.to_i
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
end
