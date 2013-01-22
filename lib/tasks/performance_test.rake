require 'performance_test/performance_test_runner'

desc "Run all performance tests"
task :run_performance_tests do
  PerformanceTestRunner.new.run
end
