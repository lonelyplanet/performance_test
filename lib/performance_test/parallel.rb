require 'timeout'

class Parallel

  GREEN = "\033[32m"
  RED = "\033[31m"
  YELLOW = "\e[33m"
  RESET = "\033[0m"

  def initialize(commands, process_count)
    @commands = commands.dup
    @process_count = process_count
    @running = {}
    @task_number = 0
  end

  def run
    @start = Time.now
    put_w_time %{Started at #{Time.now.strftime("%H:%M:%S")}}

    start_some_children
    wait_for_tasks_to_finish

    put_w_time "Elapsed time: #{distance_of_time_to_now(@start)}"
  end

  private

  def start_some_children
    while @running.length < @process_count && @commands.length > 0
      command = @commands.shift
      if !command.nil?
        @task_number += 1
        puts "Executing: #{command[:cmd]}"
        out = IO.popen(command[:cmd])
        out.pipe $stdout
        put_w_time "[#{command[:name]}] started; #{@commands.length} jobs left to start."
        command[:start] = Time.now
        command[:out] = out
        @running[out.pid] = command
      end
    end
  end

  def wait_for_tasks_to_finish
    begin
      while true do # When there are no more child processes wait2 raises Errno::ECHILD
        pid, status = Process.wait2
        command = @running.delete(pid)
        next if command.nil?
        command[:output] = command[:out].read
        command[:exitstatus] = status.exitstatus
        if status.success?
          put_w_time "#{GREEN}[#{command[:name]}] finished. Elapsed time was #{distance_of_time_to_now(command[:start])}.#{RESET}"
        else
          put_w_time "#{RED}[#{command[:name]}] failed. Elapsed time was #{distance_of_time_to_now(command[:start])}.#{RESET}\n\n"
        end
        puts_still_running
        start_some_children
      end
    rescue Errno::ECHILD
      # Errno::ECHILD indicates you have no child process to wait on.
    end
  end

  def puts_still_running
    return if @running.length == 0
    put_w_time "#{YELLOW}Still running: #{@running.values.collect{|v|v[:name]}.join(' ')}#{RESET}"
  end

  def distance_of_time_to_now(time)
    seconds = Time.now - time
    total_minutes = (seconds / 60).floor
    seconds_in_last_minute = (seconds - total_minutes * 60).floor
    "%02dm %02ds" % [total_minutes, seconds_in_last_minute]
  end

  def put_w_time(thing)
    puts %{[#{distance_of_time_to_now(@start)}] #{thing}}
  end

end