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
    # This class understands how to take an aggregate and derive a result for it.
    class ResultBuilder
      def initialize(aggregate)
        @aggregate  = aggregate
        @records    = []
        @value      = nil
        @group_ids  = Set.new
      end

      def add(record, group_id)
        if aggregate.grouped?
          return self if group_ids.include?(group_id)

          group_ids << group_id
        end

        records << record

        @value = aggregate.reduce(value, record)

        self
      end

      def result
        Result.new(aggregate.name, records, value)
      end

      private

      attr_reader :aggregate, :records, :value, :group_ids
    end
  end
end
