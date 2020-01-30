# frozen_string_literal: true

require 'rails'

module PerformanceTest
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/performance_test.rake'
    end
  end
end
