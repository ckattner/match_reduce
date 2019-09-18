# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'processor/results_builder'

module MatchReduce
  # This is the main lifecycle of the algorithm.  You initialize a new instance of this
  # class using aggregators, then you pump in records into it.  Once done, call #results
  # to get the results.
  class Processor
    extend Forwardable

    def_delegators :results_builder, :results, :resolver

    def_delegators :index, :aggregators, :any

    def initialize(aggregators, resolver: Objectable.resolver, any: ANY)
      @index            = Index.new(aggregators, any: any)
      @results_builder  = ResultsBuilder.new(index.aggregators, resolver)

      freeze
    end

    def add_each(records)
      tap { records.each { |record| add(record) } }
    end

    def add(record)
      hit_aggregators = Set.new

      record_patterns(record).each do |hash_pattern|
        # Each index find hit means the aggregator matched on the record
        index.find(hash_pattern).each do |aggregator|
          next if hit_aggregators.include?(aggregator)

          add_to_results_builder(aggregator, record)

          hit_aggregators << aggregator
        end
      end

      self
    end

    private

    attr_reader :index,
                :results_builder

    def make_group_id(aggregator, record)
      aggregator.group_keys.map { |group_key| resolver.get(record, group_key) }
    end

    def record_matrix(record)
      index.keys.each_with_object(HashMath::Matrix.new) do |key, memo|
        value = resolver.get(record, key)

        memo.add_each(key, [value, ANY])
      end
    end

    def record_patterns(record)
      [{}] + record_matrix(record).to_a
    end

    def add_to_results_builder(aggregator, record)
      group_id = make_group_id(aggregator, record)

      results_builder.add(aggregator, record, group_id)
    end
  end
end
