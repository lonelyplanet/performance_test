# performance_test

A simple gem that runs a set of cucumber features, saving the results to a database.

A typical use case might be to detect if changes made to an application have caused its performance to degrade over time.

After installing the gem, your rails application will have a new rake task called `run_performance_tests', which is driven by a config file that you create called "config/performance_test.yml".

`run_performance_tests' will execute each specified feature multiple times (as specified in the config file), aggregating the timings into to a database.

If any of the aggregated timings exceed their threshold, the rake task will return a non-zero exit code.


### Installation & Usage

#### Installation
Add this line to your applications' Gemfile.

```ruby
gem 'performance_test', github: 'lonelyplanet/performance_test'
```

Rebundle.

#### Usage

1. Write one or more cucumber features
2. Top and tail each feature with the steps "When I start the timer" and "Then I stop the timer"
3. Create a "config/performance_test.yml" file, referencing your feature(s)
4. Run the performance tests for Firefox or Chrome
  * Firefox: `bundle exec rake run_performance_tests[firefox]` (rake arg optional for Firefox)
  * Chrome : `bundle exec rake run_performance_tests[chrome]`

### Architecture

![all architects are frustrated artists](https://github.com/lonelyplanet/performance_test/blob/master/PerformanceTestGem.png)

### Configuration

Configuration is specified in a yaml file within your application ("config/performance_test.yml").

Note that we currently assume a postgresql database.

If the environment variables `APPLICATION_VERSION` and/or `BUILD_NUMBER` are defined, they will be combined and stored with the test results.

Example yaml config:

```
---
parallel-tasks:      2
db_options:
  host:     "db.results.abc"
  dbname:   "perftest_results"
  user:     "username"
  password: "password"
tests:
- name:      Example test 1
  number-of-test-runs: 10
  feature:   features/example_performance1.feature
  profile:   performance_test
  threshold_chrome: 300000
  threshold_firefox: 300000
- name:      Example test 2
  number-of-test-runs: 20
  feature:   features/example_performance2.feature
  profile:   performance_test
  threshold_chrome: 300000
  threshold_firefox: 300000
```

The test parameters used are:
```
parallel-tasks:      how many tests to run in parallel
db_options:          connection settings to save the results

tests:
  name:                 arbitrary name for the test
  number-of-test-runs:  how many times to run the test
  feature:              path to the feature that will be run (relative to the app root)
  profile:              the cucumber profile (defined by the target app, within cucumber.yml)
  threshold_chrome:     test threshold in milliseconds
  threshold_firefox:    test threshold in milliseconds
```


### Pass and Fail

Each test is run a number of times (specified by the config parameter `number-of-test-runs`), and the threshold is applied to the aggregate of the individual test timings.

The threshold determines the maximum time allowed for each test, and a pass is determined by whether the 90th percentile of the test results stays within the bounds of the threshold.

