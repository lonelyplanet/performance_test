require 'pg'
require 'json'
require 'cgi'

class ResultsRepository

  def initialize(options)
    begin
      @conn = PGconn.new options
    rescue => e
      puts "problem opening db connection: #{e}"
      puts e.backtrace
    end
  end

  def save results
    begin
      puts "saving test results to db..."
      results.each {|r| save_result(r) if r[:feature_pass] }
      puts "test results saved."
    rescue => e
      puts "problem saving performance-test results: #{e}"
      puts e.backtrace
    end
  end

  private

  def save_result(result)
    @conn.exec <<-SQL
      insert into performance_test_results
      (name, actual_time_taken, timestamp, expected_time_taken)
      values ('#{CGI.unescape(result[:name])}', #{result[:time_taken]}, '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}',#{result[:test]['threshold']});
    SQL
  end

  def create_results_table
    puts 'creating performance_test_results...'
    @conn.exec <<-SQL
      create table if not exists performance_test_results (
        name varchar(100),
        actual_time_taken int,
        expected_time_taken int,
        timestamp timestamp,
        git_hash varchar(50),
        atlas_version varchar(20),
        browser varchar(25),
        client_platform varchar(25)
      );
    SQL
  end

end