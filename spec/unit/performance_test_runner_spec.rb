require 'spec_helper'

describe PerformanceTestRunner do

  before do
    fixtureConfigPath = File.join(File.dirname(__FILE__), '..', 'fixtures', 'example_config.yml')
    @runner = PerformanceTestRunner.new fixtureConfigPath
  end

  describe '#load_config' do

    describe 'when the file exists' do
      it 'loads and parses the file' do
        @runner.config['tests'].length.should == 2
      end
    end

    describe 'when the config file doesnt exist' do
      it 'an exception is raised' do
          expect { PerformanceTestRunner.new "/some/bogus/path" }.to raise_error
      end
    end
  end

  describe '#prepare_tests' do
    it 'returns n test_instances per test, where n is the number-of-test-runs parameter from the yml' do
      @runner.tests.length.should == @runner.config['number-of-test-runs'].to_i * @runner.config['tests'].length
    end

    it 'returns test_instances with the correct keys' do
      @runner.tests[0].should have_key :name
      @runner.tests[0].should have_key :cmd
      @runner.tests[0].should have_key :test
    end
  end

  describe '#run_tests' do
    it 'calls Parallel.new with the test_instances' do

      parallel = double('parallel', run: nil)
      Parallel.should_receive(:new).with(@runner.tests, @runner.config['parallel-tasks'].to_i).and_return(parallel)

      @runner.send :run_tests
    end
  end
end