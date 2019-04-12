# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shift/api/core/version'

Gem::Specification.new do |spec|
  spec.name          = 'shift-api-core'
  spec.version       = Shift::Api::Core::VERSION
  spec.authors       = ['Shift Commerce Ltd']
  spec.email         = ['team@shiftcommerce.com']

  spec.summary       = 'Core gem for all shift commerce API gems'
  spec.description   = 'Core gem for all shift commerce API gems'
  spec.homepage      = 'https://github.com/shiftcommerce'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_runtime_dependency 'json_api_client', '~> 1.1'
end
