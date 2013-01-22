# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'performance_test/version'

Gem::Specification.new do |gem|
  gem.name          = "performance_test"
  gem.version       = PerformanceTest::VERSION
  gem.authors       = ["lonelyplanet"]
  gem.email         = ["Atlas2Ninjas@lonelyplanet.com.au"]
  gem.description   = %q{Simple framework for performance testing}
  gem.summary       = %q{Simple framework for performance testing}
  gem.homepage      = "https://github.com/lonelyplanet/performance_test"
  gem.files         = Dir[ 'Gemfile', 'LICENSE.txt', 'README.md', 'Rakefile', 'performance_test.gemspec', 'lib/tasks/performance_test.rake', 'lib/**/*.rb', 'spec/**/*.rb']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rake'
  gem.add_runtime_dependency 'pg'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'debugger'
  gem.add_development_dependency 'cucumber'
end
