require_relative 'test_init'

TestBench::Runner.(
  'automated/**/*.rb',
  exclude_pattern: %r{\/_|(_init\.rb|_tests\.rb)\z}
) or exit 1
