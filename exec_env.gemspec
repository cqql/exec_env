# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exec_env/version'

Gem::Specification.new do |spec|
  spec.name          = "exec_env"
  spec.version       = ExecEnv::VERSION
  spec.authors       = ["Marten Lienen"]
  spec.email         = ["marten.lienen@gmail.com"]
  spec.summary       = %q{Execute blocks in a manipulatable environment}
  spec.description   = %q{See README.md}
  spec.homepage      = "https://github.com/CQQL/exec_env"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.4"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "rspec"
end
