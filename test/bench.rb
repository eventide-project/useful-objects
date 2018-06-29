require_relative 'test_init'

TestBench::Runner.(
  'bench/**/*.rb',
  exclude_pattern: %r{_init\.rb\z}
) or exit 1
