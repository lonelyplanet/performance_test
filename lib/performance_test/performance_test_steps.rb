When /^I start the timer$/ do
  page.execute_script("console.profile()") if ENV['FIREBUG_PROFILE']
  @start_time = DateTime.now
end

Then /^I stop the timer$/ do
  end_time = DateTime.now
  elapsed_time = ((end_time - @start_time).to_f * 100000000).to_i
  puts "TIME_TAKEN #{elapsed_time}MS"
  if ENV['FIREBUG_PROFILE']
    page.execute_script("console.profileEnd()")
    ask <<-PROMPT, 0

    The execution was profiled with Firebug.
    Test execution will pause so you can inspect the results.
    Press Enter to continue:
    PROMPT
  end
end
