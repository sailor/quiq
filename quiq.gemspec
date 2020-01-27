# frozen_string_literal: true

require_relative 'lib/quiq/version'

Gem::Specification.new do |spec|
  spec.name          = 'quiq'
  spec.version       = Quiq::VERSION
  spec.authors       = ['Salim Semaoune']

  spec.summary       = 'amazing summary'
  spec.description   = 'gorgeous description'
  spec.homepage      = 'https://github.com/sailor/quiq'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'async-redis', '~> 0.4'
  spec.add_development_dependency 'rspec', '~> 3.2'
end
