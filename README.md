### TL;DR

1. Add `performance_test' to your Gemfile
2. Write one or more cucumber features
3. Top and tail each feature with the steps "When I start the timer" and "Then I stop the timer"
4. Create a "config/performance_test.yml" file, referencing your feature(s)
5. `bundle exec rake run_performance_tests`


### PerformanceTest

PerformanceTest is a simple gem that runs a set of cucumber features, saving the results to a database.

 A typical use case might be to detect if changes made to an application have caused its performance to degrade over time.

After installing the gem, your rails application will have a new rake task called `run_performance_tests', which is driven by a config file that you create called "config/performance_test.yml".

`run_performance_tests' will execute each specified feature multiple times (as specified in the config file), aggregating the timings into to a database.

If any of the aggregated timings exceed their threshold, the rake task will return a non-zero exit code.


### Architecture

insert pretty pic


### Configuration

Configuration is specified in a yaml file within your application ("config/performance_test.yml").

Note that we currently assume a postgresql database.

If the environment variables `APPLICATION_VERSION` and/or `BUILD_NUMBER` are defined, they will be combined and stored with the test results.

Example yaml config:

```
---
number-of-test-runs: 3
parallel-tasks:      2
db_options:
  host:     "db.results.abc"
  dbname:   "perftest_results"
  user:     "username"
  password: "password"
tests:
- name:      Example test 1
  feature:   features/example_performance1.feature
  profile:   performance_test
  threshold: 300000
- name:      Example test 2
  feature:   features/example_performance2.feature
  profile:   performance_test
  threshold: 300000
```

The test parameters used are:
```
number-of-test-runs: how many times to run each test
parallel-tasks:      how many tests to run in parallel
db_options:          connection settings to save the results

tests:
  name:      arbitrary name for the test
  feature:   path to the feature that will be run (relative to the app root)
  profile:   the cucumber profile (defined by the target app, within cucumber.yml)
  threshold: test threshold in milliseconds
```


### Pass and Fail

Each test is run a number of times (specified by the config parameter `number-of-test-runs`), and the threshold is applied to the aggregate of the individual test timings.

The threshold determines the maximum time allowed for each test, and a pass is determined by whether the 90th percentile of the test results stays within the bounds of the threshold.

