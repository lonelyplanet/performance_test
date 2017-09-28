require 'spec_helper'

def with_silent_stdout
  $stdout = File.new('/dev/null', 'w')
  yield
ensure
  $stdout = STDOUT
end

describe PerformanceTestRunner do

  let(:fixture_config_path) do
    File.join(File.dirname(__FILE__), '..', 'fixtures', 'example_config.yml')
  end

  let(:firefox_runner) { PerformanceTestRunner.new 'firefox', 'stable' }
  let(:chrome_release_runner) { PerformanceTestRunner.new 'chrome', 'stable' }
  let(:chrome_beta_runner) { PerformanceTestRunner.new 'chrome', 'beta' }


  describe 'configuration file' do
    it 'sets a sensible default' do
      expect(chrome_release_runner.instance_variable_get(:@config_path)).not_to be_nil
    end

    it 'exposes a writer for custom path' do
      custom_path = '/path/to/config.yml'
      expect {
        chrome_release_runner.config_path = custom_path
      }.to change {
        chrome_release_runner.instance_variable_get(:@config_path)
      }.to(custom_path)
    end
  end

  describe '#run_setup' do
    describe 'validating the config_file' do
      before { chrome_release_runner.config_path = 'nonexistant' }

      it 'raises an error when file not found' do
        expect { chrome_release_runner.send(:run_setup) }.to raise_error(RuntimeError)
      end
    end

    describe 'loading the configuration from config_file' do
      before do
        chrome_release_runner.config_path = fixture_config_path
        chrome_release_runner.send(:run_setup)
      end

      it 'sets and exposes configuration' do
        expect(chrome_release_runner.config.keys).to eq ['parallel-tasks','db_options','tests','results_table']
      end
    end

    describe 'setting the table for persistence' do
      describe 'when using firefox' do
        before do
          firefox_runner.config_path = fixture_config_path
          firefox_runner.send(:run_setup)
        end

        it 'persists to performance_test_results' do
          expect(firefox_runner.config['results_table']).to eq 'performance_test_results'
        end
      end

      describe 'when using chrome release' do
        before do
          chrome_release_runner.config_path = fixture_config_path
          chrome_release_runner.send(:run_setup)
        end

        it 'persists to performance_test_results_chrome' do
          expect(chrome_release_runner.config['results_table']).to eq 'performance_test_results_chrome'
        end
      end

      describe 'when using chrome beta' do
        before do
          chrome_beta_runner.config_path = fixture_config_path
          chrome_beta_runner.send(:run_setup)
        end

        it 'persists to performance_test_results_chrome_beta' do
          expect(chrome_beta_runner.config['results_table']).to eq 'performance_test_results_chrome_beta'
        end
      end
    end

    describe 'preparing the tests' do
      describe 'when using firefox' do
        before do
          firefox_runner.config_path = fixture_config_path
          firefox_runner.send(:run_setup)
        end

        it 'uses the correct test profile' do
          firefox_runner.tests[0][:cmd].should eq 'bundle exec cucumber -p performance_test features/christo/example_performance.feature 2>&1'
        end
      end

      describe 'when using chrome release' do
        before do
          chrome_release_runner.config_path = fixture_config_path
          chrome_release_runner.send(:run_setup)
        end

        it 'uses the correct test profile' do
          chrome_release_runner.tests[0][:cmd].should eq 'bundle exec cucumber -p performance_chrome features/christo/example_performance.feature 2>&1'
        end
      end

      describe 'when using chrome beta' do
        before do
          chrome_beta_runner.config_path = fixture_config_path
          chrome_beta_runner.send(:run_setup)
        end

        it 'uses the correct test profile' do
          chrome_beta_runner.tests[0][:cmd].should eq 'bundle exec cucumber -p performance_chrome features/christo/example_performance.feature 2>&1'
        end
      end

      describe 'for all browsers' do
        before do
          chrome_release_runner.config_path = fixture_config_path
          chrome_release_runner.send(:run_setup)
        end

        it 'loads and parses from the file file' do
          chrome_release_runner.config['tests'].length.should == 2
        end

        it 'returns 4 instances of test "Example test"' do
          tests = chrome_release_runner.tests.select {|test| test[:test]["name"] == "Example test"}
          tests.length.should == 4
        end

        it 'returns 2 instances of test "Example test 2"' do
          tests = chrome_release_runner.tests.select {|test| test[:test]["name"] == "Example test 2"}
          tests.length.should == 2
        end

        it 'returns test_instances with the correct keys' do
          chrome_release_runner.tests[0].should have_key :name
          chrome_release_runner.tests[0].should have_key :cmd
          chrome_release_runner.tests[0].should have_key :test
        end
      end
    end
  end

  describe '#run_tests' do
    before do
      chrome_release_runner.config_path = fixture_config_path
      chrome_release_runner.send(:run_setup)
    end

    it 'calls Parallel.new with the test_instances' do
      parallel = double('parallel', run: nil)
      Parallel.should_receive(:new).with(
        chrome_release_runner.tests,
        chrome_release_runner.config['parallel-tasks'].to_i
      ).and_return(parallel)

      with_silent_stdout { chrome_release_runner.send(:run_tests) }
    end
  end
end
