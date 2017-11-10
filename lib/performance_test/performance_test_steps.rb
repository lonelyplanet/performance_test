When /^I start the timer$/ do
  @start_time = DateTime.now
end

Then /^I stop the timer$/ do
  end_time = DateTime.now
  elapsed_time = ((end_time - @start_time).to_f * 100000000).to_i
  puts "TIME_TAKEN #{elapsed_time}MS"
end
