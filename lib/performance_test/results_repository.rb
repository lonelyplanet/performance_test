require 'pg'
require 'json'
require 'cgi'
require 'socket'

class ResultsRepository

  def initialize(options)
    @table   = options['results_table']
    begin
      @conn = PGconn.new options['db_options']
    rescue => e
      puts "ERROR: Problem opening db connection: #{e}"
      puts e.backtrace
    end
    ensure_results_table
    @hostname = Socket.gethostname
    @timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end

  def save results
    begin
      puts "Saving test results to the database"
      results.each {|r| save_result(r) if r[:feature_pass] and r[:time_taken] }
      puts "Test results saved."
    rescue => e
      puts "ERROR: Problem saving performance-test results: #{e}"
      puts e.backtrace
    end
  end

  private

  def save_result(result)
    @conn.exec <<-SQL
      insert into #{@table}
      (name, actual_time_taken, timestamp, expected_time_taken, git_hash, application_version, hostname)
      values (
        '#{CGI.unescape(result[:name])}',
        #{result[:time_taken]},
        '#{@timestamp}',
        #{result[:test]['threshold']},
        '#{result[:git_hash]}',
        '#{result[:application_version]}',
        '#{@hostname}');
    SQL
  end

  def hostname

  end

  def ensure_results_table
    puts "Ensuring #{@table} table exists"
    @conn.exec <<-SQL
      create table if not exists #{@table} (
        name varchar(100),
        actual_time_taken int,
        expected_time_taken int,
        timestamp timestamp,
        git_hash varchar(50),
        application_version varchar(20),
        browser varchar(25),
        client_platform varchar(25),
        hostname varchar(100)
      );
    SQL
  end

end