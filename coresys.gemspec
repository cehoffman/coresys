# -*- encoding: utf-8 -*-
require File.expand_path('../lib/coresys/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chris Hoffman"]
  gem.email         = ["cehoffman@gmail.com"]
  gem.description   = %q{General purpose user level package management}
  gem.summary       = %q{General prupose user level package management}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "coresys"
  gem.require_paths = ["lib"]
  gem.version       = Coresys::VERSION
end
