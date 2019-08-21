STDOUT.sync = true

require 'performance_test/results_repository'
require 'performance_test/parallel'
require 'performance_test/results_aggregator'
require 'yaml'

class PerformanceTestRunner

  attr_writer :config_path
  attr_reader :config, :tests, :results

  LOWER_THRESHOLD = 0.3

  def initialize(release = 'stable')
    @release = release

    @config_path = default_config_path
  end

  def run
    run_setup && run_tests && persist_results
  end

  private

  def default_config_path
    File.absolute_path(
      File.join(
        'config', 'performance_test.yml'
      )
    )
  end

  def validate_config_file
    if !File.exists? @config_path
      example_config_path = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', 'doc', 'performance_test.yml.example'))
      raise "ERROR: config file not found at #{@config_path}.\nSee #{example_config_path} for an example of a valid config file."
    end
  end

  def run_setup
    validate_config_file
    puts "Loading config from #{@config_path}"
    @config = YAML.load_file(@config_path)

    set_tablename_for_release

    prepare_tests
  end

  def persist_results
    @results = ResultsAggregator.aggregate @tests
    check_results_against_thresholds @results

    print_seperator
    puts "RAW RESULTS"
    puts @results

    print_seperator

    if ENV['NO_DB_RESULTS']
      puts "results NOT saved to db"
    else
      puts "SAVING RESULTS"
      ResultsRepository.new(@config).save(@results)
    end
    handle_results @results
  end

  def print_seperator
    puts "#{'-'*100}\n"
  end

  def prepare_tests
    @tests = @config['tests'].flat_map do |test|
      number_of_test_runs = test['number-of-test-runs'] || 1
      (1..number_of_test_runs).map do |i|
        {
          name: "#{test['name']} - Run #{i}",
          cmd: "bundle exec cucumber -p performance #{test['feature']} 2>&1",
          test: test
        }
      end
    end
  end

  def run_tests
    time_taken_re = /TIME_TAKEN ([0-9]+)MS/

    p @tests
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
    results.each do |result|
      time_taken = result[:time_taken]
      threshold = result[:test]['threshold'].to_i

      if !time_taken
        result[:threshold_pass] = false
        result[:message] = "Failed: '#{result[:name]}: because no timing was recorded"

      elsif time_taken < (threshold * LOWER_THRESHOLD)
        result[:threshold_pass] = false
        result[:message] = "Failed: '#{result[:name]}': aggregate time taken (#{time_taken}ms) was less than #{LOWER_THRESHOLD} times the threshold (#{threshold * LOWER_THRESHOLD}ms)"

      elsif time_taken > threshold
        result[:threshold_pass] = false
        result[:message] = "Failed: '#{result[:name]}': aggregate time taken (#{time_taken}ms) was greater than the threshold (#{threshold}ms)"
      else
        result[:threshold_pass] = true
        result[:message] = "Pass:   '#{result[:name]}'"
      end
    end
    log_to_console results
  end

  def log_to_console(results)
    print_seperator
    puts "AGGREGATED RESULTS"
    puts

    # list failures first
    results.each {|result| puts result[:message] if !result[:threshold_pass]}
    puts
    results.each {|result| puts result[:message] if  result[:threshold_pass]}
  end

  def handle_results(results)
    print_seperator
    if results.all? {|r| r[:threshold_pass] && r[:feature_pass]}
      puts "Final result: All tests passed"
    else
      raise "Final result: Some tests failed"
    end
  end

  def set_tablename_for_release
    table =  'performance_test_results_chrome'
    table += '_beta' if is_beta?

    @config['results_table'] = table
  end

  def is_beta?
    @release == 'beta'
  end
end
