# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'result_builder'

module MatchReduce
  class Processor
    # This class knows how to group together aggregates in order to produce results.
    class ResultsBuilder
      def initialize(aggregates)
        @result_by_name = aggregates.map { |a| [a.name, ResultBuilder.new(a)] }.to_h

        freeze
      end

      def add(aggregate, record, group_id)
        tap { result_by_name[aggregate.name].add(record, group_id) }
      end

      def results
        result_by_name.values.map(&:result)
      end

      private

      attr_reader :result_by_name
    end
  end
end
