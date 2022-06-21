lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'railsdock/version'

Gem::Specification.new do |spec|
  spec.name          = 'railsdock'
  spec.license       = 'MIT'
  spec.version       = Railsdock::VERSION
  spec.authors       = ['Kyle Boe', 'Nate Vick']
  spec.email         = ['kyle@hint.io', 'nate.vick@hint.io']

  spec.summary       = 'Docker-ize your Rails project.'
  spec.description   = 'CLI Application for adding Docker configuration to your Rails application.'
  spec.homepage      = 'https://github.com/hintmedia/railsdock'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either
  # set the 'allowed_push_host' to allow pushing to a single host
  # or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/hintmedia/railsdock'
    spec.metadata['changelog_uri'] = 'https://github.com/hintmedia/railsdock/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions    = ['ext/railsdock/extconf.rb']

  spec.add_dependency 'railties', '>= 4.2', '< 7.1'
  spec.add_dependency 'bundler', '~> 2.0'
  spec.add_dependency 'pastel', '~> 0.7'
  spec.add_dependency 'thor', '~> 1.0'
  spec.add_dependency 'tty-command', '~> 0.10'
  spec.add_dependency 'tty-file', '~> 0.10'
  spec.add_dependency 'tty-platform', '~> 0.3'
  spec.add_dependency 'tty-prompt', '~> 0.19'

  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rake-compiler'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'appraisal', '2.2'
  spec.add_development_dependency 'pry-rails'
end
