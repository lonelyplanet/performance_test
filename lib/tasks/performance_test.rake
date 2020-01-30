# frozen_string_literal: true

require 'performance_test/performance_test_runner'

desc 'Run all performance tests against release'
task :run_performance_tests_release do
  PerformanceTestRunner.new('release').run
end

desc 'Run all performance tests against beta'
task :run_performance_tests_beta do
  PerformanceTestRunner.new('beta').run
end
