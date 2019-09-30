# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'execution_deadline/version'

Gem::Specification.new do |spec|
  spec.name          = 'execution_deadline'
  spec.version       = ExecutionDeadline::VERSION
  spec.authors       = ['Brian Malinconico']

  spec.summary       = 'Manage code deadlines without the hard termination of Timeout'
  spec.description   = 'Easily create and enforce deadline timings for code without the harsh termination of the Timeout module.'
  spec.homepage      = 'https://github.com/arjes/execution_deadline'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
