require 'performance_test/performance_test_runner'

desc "Run all performance tests"
task :run_performance_tests, [:browser] do |t,args|
  browser = args[:browser] || 'firefox'
  PerformanceTestRunner.new(browser).run
end
