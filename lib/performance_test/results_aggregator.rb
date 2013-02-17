class ResultsAggregator

	def self.aggregate(results)
		grouped_tests_results = results.group_by { |r| r[:test] }
		git_hash   = `git rev-parse HEAD`.chomp

		aggregates = []
		grouped_tests_results.each do |test, test_results|
			feature_pass = test_results.all? { |result| result[:exitstatus] == 0 }
			test_timings = test_results.map { |result| result[:time_taken] }
			test_timings = [0] if test_timings.nil?
			aggregates << {
				:name => test['name'],
				:time_taken => find_percentile(test_timings, 50),
				:feature_pass => feature_pass,
        :git_hash => git_hash,
        :application_version => app_version,
				:test => test
			}
		end
		aggregates
	end

	def self.find_percentile(list, percentile)
		list.sort[((list.size - 1) * percentile / 100.0).round]
	end

	def self.app_version
		version      = ENV['APPLICATION_VERSION']
		build_number = ENV['BUILD_NUMBER']
		if version && build_number
			"#{version}.#{build_number}"
		else
			"#{version}#{build_number}"
		end
	end

end