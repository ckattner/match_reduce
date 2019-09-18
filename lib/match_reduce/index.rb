# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MatchReduce
  # The Index holds all the aggregators, the reverse lookup data structure, and the ability
  # to retrieve aggregators based on a pattern
  class Index
    extend Forwardable

    attr_reader :aggregators,
                :any,
                :lookup

    def_delegators :record, :keys

    def initialize(aggregators = [], any: ANY)
      @any = any
      @aggregators = Aggregator.array(aggregators).uniq(&:name)
      @lookup = {}

      all_keys = @aggregators.flat_map(&:keys)
      @record  = HashMath::Record.new(all_keys, any)

      @aggregators.map do |aggregator|
        aggregator.patterns.each do |pattern|
          normalized_pattern = record.make!(pattern)

          get(normalized_pattern) << aggregator
        end
      end

      freeze
    end

    def find(pattern)
      lookup.fetch(pattern, [])
    end

    private

    attr_reader :record

    def get(normalized_pattern)
      lookup[normalized_pattern] ||= Set.new
    end
  end
end
