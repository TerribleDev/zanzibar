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
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rubyntlm', '~> 0.4.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~>0.18.1'
  spec.add_runtime_dependency 'savon', '~> 2.8.0'
end
