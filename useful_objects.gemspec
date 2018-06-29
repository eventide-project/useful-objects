# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'useful_objects'
  s.version = '0.0.0'
  s.summary = 'Useful Objects Example'
  s.description = ' '

  s.authors = ['Useful Objects']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.3'

  s.add_runtime_dependency 'evt-dependency'
  s.add_runtime_dependency 'evt-initializer'
  s.add_runtime_dependency 'evt-telemetry'
  s.add_runtime_dependency 'evt-configure'

  s.add_development_dependency 'test_bench'
end
