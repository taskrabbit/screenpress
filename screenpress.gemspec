# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'screenpress/version'

Gem::Specification.new do |spec|
  spec.name          = "screenpress"
  spec.version       = Screenpress::VERSION
  spec.authors       = ["Brian Leonard"]
  spec.email         = ["brian@bleonard.com"]
  spec.description   = %q{Workflow and Capybara extension that takes screenshots of your tests to prevent visual regressions}
  spec.summary       = %q{Prevent visual regressions}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "capybara"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_development_dependency("rspec")
end
