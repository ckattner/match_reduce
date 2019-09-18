# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'result'

module MatchReduce
  class Processor
    # This class understands how to take an aggregator and derive a result for it.
    class ResultBuilder
      def initialize(aggregator, resolver)
        raise ArgumentError, 'aggregator is required' unless aggregator
        raise ArgumentError, 'resolver is required' unless resolver

        @aggregator = aggregator
        @resolver = resolver

        @records    = []
        @value      = nil
        @group_ids  = Set.new
      end

      def add(record, group_id)
        if aggregator.grouped?
          return self if group_ids.include?(group_id)

          group_ids << group_id
        end

        records << record

        @value = aggregator.reduce(value, record, resolver)

        self
      end

      def result
        Result.new(aggregator.name, records, value)
      end

      private

      attr_reader :aggregator,
                  :group_ids,
                  :records,
                  :resolver,
                  :value
    end
  end
end
