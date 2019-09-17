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
  # class using aggregates, then you pump in records into it.  Once done, call #results
  # to get the results.
  class Processor
    extend Forwardable

    def_delegators :results_builder, :results, :resolver

    def_delegators :index, :aggregates

    def initialize(aggregates, resolver)
      @index            = Index.new(aggregates)
      @results_builder  = ResultsBuilder.new(index.aggregates, resolver)

      freeze
    end

    def add_each(records)
      tap { records.each { |record| add(record) } }
    end

    def add(record)
      hit_aggregates = Set.new

      record_patterns(record).each do |hash_pattern|
        # Each index find hit means the aggregate matched on the record
        index.find(hash_pattern).each do |aggregate|
          next if hit_aggregates.include?(aggregate)

          add_to_results_builder(aggregate, record)

          hit_aggregates << aggregate
        end
      end

      self
    end

    private

    attr_reader :index,
                :results_builder

    def make_group_id(aggregate, record)
      aggregate.group_keys.map { |group_key| resolver.get(record, group_key) }
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

    def add_to_results_builder(aggregate, record)
      group_id = make_group_id(aggregate, record)

      results_builder.add(aggregate, record, group_id)
    end
  end
end
