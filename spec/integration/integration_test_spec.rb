require 'spec_helper'

RSpec.shared_examples "records the correct results" do
  it "should record the correct results" do
    # should fail the first test because the threshold is exceeded
    expect(@runner.results[0][:threshold_pass]).to eq false

    # should pass the second test
    expect(@runner.results[1][:threshold_pass]).to eq true
    expect(@runner.results[1][:feature_pass]).to eq true

    # should fail the third test because the cucumber feature doesn't exist
    expect(@runner.results[2][:feature_pass]).to eq false
  end
end

describe PerformanceTest do

  before(:each) do

    repository = double('repository')
    repository.should_receive(:save).once
    ResultsRepository.should_receive(:new).and_return(repository)

    @fixtureConfigPath = File.join(File.dirname(__FILE__), '..', 'fixtures', 'integration_test.yml')
  end

  describe 'when running against firefox' do
    before do
      @runner = PerformanceTestRunner.new 'firefox', @fixtureConfigPath
      begin
        @runner.run
      rescue
      end
    end

    it 'uses the correct threshold' do
      expect(@runner.results[0][:test]['threshold']).to eq 1
      expect(@runner.results[1][:test]['threshold']).to eq 6000
      expect(@runner.results[2][:test]['threshold']).to eq 400000
    end

    include_examples "records the correct results"
  end

  describe 'when running against chrome' do
    before do
      @runner = PerformanceTestRunner.new 'chrome', @fixtureConfigPath
      begin
        @runner.run
      rescue
      end
    end

    it 'uses the correct threshold' do
      expect(@runner.results[0][:test]['threshold']).to eq 1
      expect(@runner.results[1][:test]['threshold']).to eq 5000
      expect(@runner.results[2][:test]['threshold']).to eq 300000
    end

    include_examples "records the correct results"
  end
end