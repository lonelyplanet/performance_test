require 'spec_helper'
require 'debugger'

describe PerformanceTest do

  FIXTURE_CONFIG_PATH = File.join(File.dirname(__FILE__), '..', 'fixtures', 'integration_test.yml')

  before(:each) do
    repository = double('repository')
    repository.should_receive(:save).once
    ResultsRepository.should_receive(:new).and_return(repository)

    @runner = PerformanceTestRunner.new FIXTURE_CONFIG_PATH
    @runner.run
  end

  # currently can't figure out a way of having a single before block with multiple test runs...

  it "should record the correct results" do
    # should fail the first test because the threshold is exceeded
    @runner.results[0][:threshold_pass].should be_false

    # should pass the second test
    @runner.results[1][:threshold_pass].should be_true

    # should fail the third test because the cucumber feature doesn't exist
    @runner.results[2][:feature_pass].should be_false
  end

end
