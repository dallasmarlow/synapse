# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synapse/version'

Gem::Specification.new do |gem|
  gem.name          = "synapse-marathon"
  gem.version       = Synapse::VERSION

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_runtime_dependency "aws-sdk", "~> 1.39"
  gem.add_runtime_dependency "docker-api", "~> 1.7.2"
  gem.add_runtime_dependency "zk", "~> 1.9.4"
  gem.add_runtime_dependency "marathon_client", "~> 0.3.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", "~> 3.1.0"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-nav"
end
