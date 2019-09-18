# MatchReduce

[![Gem Version](https://badge.fury.io/rb/match_reduce.svg)](https://badge.fury.io/rb/match_reduce) [![Build Status](https://travis-ci.org/bluemarblepayroll/match_reduce.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/match_reduce) [![Maintainability](https://api.codeclimate.com/v1/badges/a441f1405041cd7a0807/maintainability)](https://codeclimate.com/github/bluemarblepayroll/match_reduce/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/a441f1405041cd7a0807/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/match_reduce/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

MatchReduce is a high-speed, in-memory data aggregation and reduction algorithm.  The lifecycle is:

1. define aggregators
2. pump records into algorithm
3. grab results

The dataset will only be processed once no matter how many aggregators you define.  An aggregator is expressed as:

* patterns: an array of hashes, which are used to pattern match records
* reducer: a function, which is used when a record matches
* group_keys: key or keys to uniquely semantically identify records, so records do not get added multiple times.  This is extremely beneficial for denormalized datasets where data may exist at row and/or column-level.

## Installation

To install through Rubygems:

````bash
gem install install match_reduce
````

You can also add this to your Gemfile:

````bash
bundle add match_reduce
````

## Examples

### Getting Started

A very basic example of calling this library would be:

````ruby
require 'match_reduce'

aggregators = [
 {
   name: :total_game_points
   reducer: ->(memo, record, resolver) { memo.to_i + resolver.get(record, :game_points).to_i },
   group_keys: :game
 }
]

records = [
  { game: 1, game_points: 199, team: 'Bulls', team_points: 100 },
  { game: 1, game_points: 199, team: 'Celtics', team_points: 99 },
  { game: 2, game_points: 240, team: 'Rockets', team_points: 130 },
  { game: 2, game_points: 240, team: 'Bulls', team_points: 110 }
]

results = MatchReduce.process(aggregators, records)
````

`results` would be equal to:

````ruby
[
  MatchReduce::Processor::Result.new(
    name: :total_game_points,
    records: [
      { game: 1, game_points: 199, team: 'Bulls', team_points: 100 },
      { game: 2, game_points: 240, team: 'Rockets', team_points: 130 }
    ],
    value: 439
  )
]
````

Notes:

* Not specifying patterns, as in the example above, means: "match on everything"
* group_keys will limit the records matched on, per aggregator, to the first record only.  This is why only the first and third records matched.
* keys are type-indifferent and will extracted using (the Objectable library)[https://github.com/bluemarblepayroll/objectable].  This means you can leverage dot-notation, non-hash record types, and indifference.  You can also customize the resolver used and pass it as a third argument to MatchReduce#process(aggregators, records, resolver).
* Names of aggregators are type-sensitive, so: `:total_game_points` and `'total_game_points'` are two different aggregators and will produce two different results.

### Adding Patterns

Let's say we want to discretely know how many points the Bulls, Celtics, and Rockets have scored, we could do this:

````ruby
require 'match_reduce'

aggregators = [
 {
   name: :bulls_points
   patterns: { team: 'Bulls' },
   reducer: ->(memo, record, resolver) { memo.to_i + resolver.get(record, :team_points).to_i },
   group_keys: :game
 },
 {
   name: :celtics_points
   patterns: { team: 'Celtics' },
   reducer: ->(memo, record, resolver) { memo.to_i + resolver.get(record, :team_points).to_i },
   group_keys: :game
 },
 {
   name: :rockets_points
   patterns: { team: 'Rockets' },
   reducer: ->(memo, record, resolver) { memo.to_i + resolver.get(record, :team_points).to_i },
   group_keys: :game
 }
]

records = [
  { game: 1, game_points: 199, team: 'Bulls', team_points: 100 },
  { game: 1, game_points: 199, team: 'Celtics', team_points: 99 },
  { game: 2, game_points: 240, team: 'Rockets', team_points: 130 },
  { game: 2, game_points: 240, team: 'Bulls', team_points: 110 }
]

results = MatchReduce.process(aggregators, records)
````

`results` would now be equal to:

````ruby
[
  MatchReduce::Processor::Result.new(
    name: :bulls_points,
    records: [
      { game: 1, game_points: 199, team: 'Bulls', team_points: 100 },
      { game: 2, game_points: 240, team: 'Bulls', team_points: 110 }
    ],
    value: 210
  ),
  MatchReduce::Processor::Result.new(
    name: :celtics_points,
    records: [
      { game: 1, game_points: 199, team: 'Celtics', team_points: 99 },
    ],
    value: 99
  ),
  MatchReduce::Processor::Result.new(
    name: :rockets_points,
    records: [
      { game: 2, game_points: 240, team: 'Rockets', team_points: 130 },
    ],
    value: 130
  ),
]
````

We could also choose to aggregator multiple teams together by providing multiple patterns:

````ruby
require 'match_reduce'

aggregators = [
 {
   name: :bulls_and_celtics_points
   patterns: [
     { team: 'Bulls' },
     { team: 'Celtics' }
   ],
   reducer: ->(memo, record, resolver) { memo.to_i + resolver.get(record, :team_points).to_i },
   group_keys: :game
 },
]

records = [
  { game: 1, game_points: 199, team: 'Bulls', team_points: 100 },
  { game: 1, game_points: 199, team: 'Celtics', team_points: 99 },
  { game: 2, game_points: 240, team: 'Rockets', team_points: 130 },
  { game: 2, game_points: 240, team: 'Bulls', team_points: 110 }
]

results = MatchReduce.process(aggregators, records)
````

`results` would now be equal to:

````ruby
[
  MatchReduce::Processor::Result.new(
    name: :bulls_and_celtics_points,
    records: [
      { game: 1, game_points: 199, team: 'Bulls', team_points: 100 },
      { game: 1, game_points: 199, team: 'Celtics', team_points: 99 },
      { game: 2, game_points: 240, team: 'Bulls', team_points: 110 }
    ],
    value: 309
  )
]
````

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check match_reduce.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/match_reduce.git)
4. Navigate to the root folder (cd match_reduce)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite and code-coverage tool, run:

````bash
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````bash
bundle exec guard
````

Also, do not forget to run Rubocop:

````bash
bundle exec rubocop
````

or run all three in one command:

````bash
bundle exec rake
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/match_reduce/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bluemarblepayroll/match_reduce/blob/master/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
