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
    # This class knows how to group together aggregators in order to produce results.
    class ResultsBuilder
      attr_reader :resolver

      def initialize(aggregators, resolver)
        raise ArgumentError, 'aggregators are required' unless aggregators

        @result_by_name = aggregators.map { |a| [a.name, ResultBuilder.new(a, resolver)] }.to_h
        @resolver       = resolver

        freeze
      end

      def add(aggregator, record, group_id)
        tap { result_by_name[aggregator.name].add(record, group_id) }
      end

      def results
        result_by_name.values.map(&:result)
      end

      private

      attr_reader :result_by_name
    end
  end
end
