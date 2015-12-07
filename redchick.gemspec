# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redchick/version'

Gem::Specification.new do |spec|
  spec.name          = "redchick"
  spec.version       = Redchick::VERSION
  spec.authors       = ["saki"]
  spec.email         = ["sakihet@gmail.com"]

  spec.summary       = %q{twitter client}
  spec.description   = %q{twitter client}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'oauth', '~> 0.4.7'
  spec.add_runtime_dependency 'twitter', '~> 5.15'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
