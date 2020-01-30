# frozen_string_literal: true

When /^I delay for (\d+) seconds$/ do |count|
  sleep count.to_i
end
