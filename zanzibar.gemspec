# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zanzibar/version'

Gem::Specification.new do |spec|
  spec.name          = 'zanzibar'
  spec.version       = Zanzibar::VERSION
  spec.authors       = ['Jason Davis-Cooke']
  spec.email         = ['jdaviscooke@cimpress.com']
  spec.summary       = 'Retrieve secrets from Secret Server'
  spec.description   = 'Programatically get secrets from Secret Server via the Web Service API'
  spec.homepage      = 'https://github.com/Cimpress-MCP/zanzibar'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin\/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)\/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.39.0'
  spec.add_development_dependency 'savon_spec', '~> 0.1.6'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'webmock', '~> 1.20.4'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'fakefs', '~> 0.6.4'
  spec.add_development_dependency 'simplecov', '~> 0.9.1'

  spec.add_runtime_dependency 'savon', '~> 2.11.0'
  spec.add_runtime_dependency 'rubyntlm', '~> 0.6.0'
  spec.add_runtime_dependency 'thor', '~> 0.19.0'
end
