# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MatchReduce
  # The Index holds all the aggregates, the reverse lookup data structure, and the ability
  # to retrieve aggregates based on a pattern
  class Index
    extend Forwardable

    attr_reader :aggregates,
                :any,
                :lookup

    def_delegators :record, :keys

    def initialize(aggregates = [], any: ANY)
      @any        = any
      @aggregates = Aggregate.array(aggregates).uniq(&:name)
      @lookup     = {}

      all_keys = @aggregates.flat_map(&:keys)
      @record  = HashMath::Record.new(all_keys, any)

      @aggregates.map do |aggregate|
        aggregate.patterns.each do |pattern|
          normalized_pattern = record.make!(pattern)

          get(normalized_pattern) << aggregate
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
