# frozen_string_literal: true

require_relative 'lib/markawesome/version'

Gem::Specification.new do |spec|
  spec.name          = 'markawesome'
  spec.version       = Markawesome::VERSION
  spec.authors       = ['Janne Waren']
  spec.email         = ['janne.waren@iki.fi']

  spec.summary       = 'Framework-agnostic Markdown to Web Awesome component transformer'
  spec.description   = 'A library that transforms custom Markdown syntax into Web Awesome components. ' \
                       'Framework-agnostic and can be used with Jekyll, Hugo, or any other static site generator.'
  spec.homepage      = 'https://github.com/jannewaren/markawesome'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/main"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    Dir.glob('lib/**/*.rb') + %w[
      README.md
      CHANGELOG.md
      LICENSE.txt
      markawesome.gemspec
    ]
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'kramdown', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
end
