require 'spec_helper'

def with_silent_stdout
  $stdout = File.new('/dev/null', 'w')
  yield
ensure
  $stdout = STDOUT
end

describe PerformanceTestRunner do

  before do
    fixtureConfigPath = File.join(File.dirname(__FILE__), '..', 'fixtures', 'example_config.yml')
    @runner = PerformanceTestRunner.new 'chrome', fixtureConfigPath
  end

  describe '#load_config' do

    describe 'when the file exists' do
      it 'loads and parses the file' do
        @runner.config['tests'].length.should == 2
      end
    end

    describe 'when the config file doesnt exist' do
      it 'an exception is raised' do
          expect { PerformanceTestRunner.new 'chrome', '/some/bogus/path' }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#prepare_tests' do
    it 'returns 4 instances of test "Example test"' do
      tests = @runner.tests.select {|test| test[:test]["name"] == "Example test"}
      tests.length.should == 4
    end

    it 'returns 2 instances of test "Example test 2"' do
      tests = @runner.tests.select {|test| test[:test]["name"] == "Example test 2"}
      tests.length.should == 2
    end

    it 'returns test_instances with the correct keys' do
      @runner.tests[0].should have_key :name
      @runner.tests[0].should have_key :cmd
      @runner.tests[0].should have_key :test
    end

    it 'uses the correct test profile' do
      @runner.tests[0][:cmd].should eq 'bundle exec cucumber -p performance_chrome features/christo/example_performance.feature 2>&1'
    end
  end

  describe '#run_tests' do
    it 'calls Parallel.new with the test_instances' do

      parallel = double('parallel', run: nil)
      Parallel.should_receive(:new).with(@runner.tests, @runner.config['parallel-tasks'].to_i).and_return(parallel)

      with_silent_stdout do
        @runner.send :run_tests
      end
    end
  end

end