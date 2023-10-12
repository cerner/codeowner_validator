# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codeowner_validator/version'

Gem::Specification.new do |spec|
  spec.name          = 'codeowner_validator'
  spec.version       = CodeownerValidator::VERSION
  spec.authors       = ['Greg Howdeshell']
  spec.email         = ['greg.howdeshell@gmail.com']

  spec.summary       = 'Write a short summary, because RubyGems requires one.'
  spec.description = <<~DESC
    GitHub CODEOWNERS validator
  DESC
  spec.homepage      = 'https://github.com/cerner/codeowner_validator'
  spec.license       = 'Apache-2.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(/^(test|spec|features)\//) }
    end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # rubocop:disable Gemspec/RequiredRubyVersion
  # The intent is for supportability from ruby 2.7 and greater
  spec.required_ruby_version = '>= 2.7.2'
  # rubocop:enable Gemspec/RequiredRubyVersion

  spec.add_dependency 'rainbow', '>= 2.0', '< 4.0.0'
  spec.add_dependency 'thor', '>= 1.0'

  spec.add_dependency 'tty-prompt', '~> 0.12'
  spec.add_dependency 'tty-spinner', '~> 0.4'
  spec.add_dependency 'tty-table', '~> 0.8'

  # spec.add_dependency 'codeowners-checker', '~> 1.1'
  spec.add_dependency 'pathspec', '~> 0.2.0'
  spec.add_dependency 'git', '~> 1.0'
end
