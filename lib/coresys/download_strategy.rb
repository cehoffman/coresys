module Coresys
  module DownloadStrategy
    autoload :Abstract, 'coresys/download_strategy/abstract'
    autoload :Archive, 'coresys/download_strategy/archive'
    autoload :Curl, 'coresys/download_strategy/curl'
    autoload :Git, 'coresys/download_strategy/git'

    def self.guess(formula)
      case formula.url
      when %r{^git://|\.git$} then Git.new(formula)
      when %r{^(https?|ftp)://} then Curl.new(formula)
      end
    end
  end
end
