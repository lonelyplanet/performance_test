require 'performance_test/performance_test_runner'

desc "Run all performance tests"
task :run_performance_tests, [:browser,:release] do |t,args|
  PerformanceTestRunner.new(args[:browser], args[:release]).run
end

desc "Run all performance tests against Chrome release"
task :run_performance_tests_chrome_release do
  PerformanceTestRunner.new('chrome', 'release').run
end

desc "Run all performance tests against Chrome beta"
task :run_performance_tests_chrome_beta do
  PerformanceTestRunner.new('chrome', 'beta').run
end

desc "Run all performance tests against Firefox"
task :run_performance_tests_firefox do
  PerformanceTestRunner.new('firefox', 'stable').run
end
