require 'performance_test/performance_test_runner'

desc "Run all performance tests"
task :run_performance_tests, [:browser] do |t,args|
  browser = args[:browser] || 'firefox'
  release = 'stable'
  PerformanceTestRunner.new(browser, release).run
end

desc "Run all performance tests against Chrome release"
task :run_performance_tests_chrome_release do
  browser = 'chrome'
  release = 'release'
  PerformanceTestRunner.new(browser, release).run
end

desc "Run all performance tests against Chrome beta"
task :run_performance_tests_chrome_beta do
  browser = 'chrome'
  release = 'beta'
  PerformanceTestRunner.new(browser, release).run
end

desc "Run all performance tests against Firefox"
task :run_performance_tests_chrome_firefox do
  browser = 'firefox'
  release = 'stable'
  PerformanceTestRunner.new(browser, release).run
end
