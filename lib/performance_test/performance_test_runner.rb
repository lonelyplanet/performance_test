STDOUT.sync = true

require 'performance_test/results_repository'
require 'performance_test/parallel'
require 'performance_test/results_aggregator'
require 'yaml'

class PerformanceTestRunner

  attr_accessor :config, :tests, :results

  STEPS_PATH = File.absolute_path(File.join(File.dirname(__FILE__),'performance_test_steps.rb'))
  CONFIG_PATH = File.absolute_path(File.join('config', 'performance_test.yml'))
  LOWER_THRESHOLD = 0.3

  def initialize(config_path = CONFIG_PATH)
    if !File.exists? config_path
      exampleConfigPath = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', 'doc', 'performance_test.yml.example'))
      raise "ERROR: config file not found at #{config_path}.\nSee #{exampleConfigPath} for an example of a valid config file."
    end

    puts "Loading config from #{config_path}"
    @config = YAML.load_file(config_path)
    @tests  = prepare_tests
  end

  def run
    run_tests
    @results = ResultsAggregator.aggregate @tests
    check_results_against_thresholds @results

    print_seperator
    puts "RAW RESULTS"
    puts @results

    print_seperator
    puts "SAVING RESULTS"
    results_repo = ResultsRepository.new @config['db_options']
    results_repo.save @results

    set_exit_code @results
  end

  private

  def print_seperator
    puts "#{'-'*100}\n"
  end

  def prepare_tests
    @config['tests'].map do |test|
      number_of_test_runs = test['number-of-test-runs']
      (1..number_of_test_runs).map do |i|
        {
          name: "#{test['name']} - Run #{i}",
          cmd: "bundle exec cucumber --require #{STEPS_PATH} -p #{test['profile']} #{test['feature']} 2>&1",
          test: test
        }
      end
    end.flatten
  end

  def run_tests
    time_taken_re = /TIME_TAKEN ([0-9]+)MS/

    Parallel.new(@tests, @config['parallel-tasks'].to_i).run

    @tests.collect do |test|
      response = test[:output]

      print_seperator
      puts test[:cmd]

      if response =~ time_taken_re
        test[:time_taken] = time_taken_re.match(response)[1].to_i if test[:exitstatus] == 0
        puts "Time taken was #{test[:time_taken]}ms"
      else
        puts "ERROR: No 'TIME_TAKEN' found in cucumber output for '#{test[:name]}'. Have you included the 'Then I stop the timer' step?"
      end

      puts response

    end

    @tests
  end

  def check_results_against_thresholds(results)
    print_seperator
    puts "AGGREGATED RESULTS"

    results.each do |result|
      time_taken = result[:time_taken]
      threshold = result[:test]['threshold'].to_i

      if !time_taken
        result[:threshold_pass] = false
        puts "Test '#{result[:name]} failed because no timing was recorded"
      elsif time_taken < (threshold * LOWER_THRESHOLD)
        result[:threshold_pass] = false
        puts "Test '#{result[:name]}' failed because its aggregate time taken (#{time_taken}ms) was less than #{LOWER_THRESHOLD} times the threshold (#{threshold * LOWER_THRESHOLD}ms)"
      elsif time_taken > threshold 
        result[:threshold_pass] = false
        puts "Test '#{result[:name]}' failed because its aggregate time taken (#{time_taken}ms) was greater than the threshold (#{threshold}ms)"
      else
        result[:threshold_pass] = true
        puts "Test '#{result[:name]}' passed"
      end
    end
  end

  def set_exit_code(results)
    print_seperator
    if results.all? {|r| r[:threshold_pass] && r[:feature_pass]} 
      puts "Final result: All tests passed"
      exit 0
    else
      puts "Final result: Some tests failed"
      exit 1
    end
  end
end