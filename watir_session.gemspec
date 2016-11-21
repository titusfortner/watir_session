# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'watir_session'
  spec.version       = '0.2.3'
  spec.authors       = ['Titus Fortner']
  spec.email         = ['titusfortner@gmail.com']

  spec.summary       = %q{Allows easy access to configuration and session data for Watir tests.}
  spec.description   = %q{This gem leverages the Watir test library to allow for easy access
to configurarion and session data so they do not need to be passed around as parameters throughout your tests.}
  spec.homepage      = 'https://github.com/titusfortner/watir_session'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'watir', '~> 6.0'
  spec.add_runtime_dependency 'watir_model', '~> 0.2'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

end
