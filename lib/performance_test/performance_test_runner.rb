STDOUT.sync = true

require 'performance_test/results_repository'
require 'performance_test/parallel'
require 'performance_test/results_aggregator'
require 'yaml'

class PerformanceTestRunner

  attr_accessor :config, :tests, :results

  STEPS_PATH = File.absolute_path(File.join(File.dirname(__FILE__),'performance_test_steps.rb'))
  CONFIG_PATH = File.absolute_path(File.join('config', 'performance_test.yml'))

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
    puts @results
    results_repo = ResultsRepository.new @config['db_options']
    results_repo.save @results
    results_pass? @results
  end

  private

  def prepare_tests
    @config['tests'].map do |test|
      number_of_test_runs = test['number-of-test-runs']
      (1..number_of_test_runs).map do |i|
        puts "bundle exec cucumber --require #{STEPS_PATH} -p #{test['profile']} #{test['feature']} 2>&1"
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

    log_file = File.open("run.log", "w")
    @tests.collect do |test|
      response = test[:output]
      if response =~ time_taken_re
        test[:time_taken] = time_taken_re.match(response)[1].to_i if test[:exitstatus] == 0
        log_file << "#{test[:cmd]}\n#{test[:output]}\n#{'-'*100}\n"
      else
        puts "ERROR: No 'TIME_TAKEN' found in cucumber output. Have you included the 'Then I stop the timer' step?\nThe cucumber output was:"
        puts response
      end
    end
    log_file.close

    @tests
  end

  def check_results_against_thresholds(results)
    results.each do |result|
      result[:threshold_pass] = result[:time_taken] && compatible_with_threshold(result[:time_taken], result[:test]['threshold'])
    end
  end

  def compatible_with_threshold(time_taken, threshold)
    time_taken > (threshold * 0.5) and time_taken < threshold 
  end

  def results_pass?(results)
    results.all? {|r| r[:threshold_pass] && r[:feature_pass]}
  end
end