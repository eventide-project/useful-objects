ENV['TEST_BENCH_EXCLUDE_PATTERN'] ||= '/_|sketch|(_init\.rb|_tests\.rb)\z'
ENV['TEST_BENCH_TESTS_DIR'] ||= 'test/automated'

require_relative './test_init'

require 'test_bench/cli'

TestBench::CLI.() or exit 1
