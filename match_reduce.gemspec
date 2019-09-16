# frozen_string_literal: true

require './lib/match_reduce/version'

Gem::Specification.new do |s|
  s.name        = 'match_reduce'
  s.version     = MatchReduce::VERSION
  s.summary     = 'Data matching and aggregation framework'

  s.description = <<-DESCRIPTION
    This library take a dataset and pattern matchers and sifts the dataset into the appropriate matchers.  Each matcher can then reduce down the matching data.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.homepage    = 'https://github.com/bluemarblepayroll/match_reduce'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.4.6'

  s.add_dependency('acts_as_hashable', '~>1', '>=1.1.0')
  s.add_dependency('objectable', '~>1')

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pry', '~>0')
  s.add_development_dependency('rake', '~> 12')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop', '~>0.74.0')
  s.add_development_dependency('simplecov', '~>0.17.0')
  s.add_development_dependency('simplecov-console', '~>0.5.0')
end
