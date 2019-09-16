# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MatchReduce
  class Processor
    # This is the main resulting value object returned, one per aggregate.
    class Result
      attr_reader :name, :records, :value

      def initialize(name, records, value)
        @name     = name
        @records  = records
        @value    = value

        freeze
      end

      def hash
        [name, records, value].hash
      end

      def ==(other)
        other.instance_of?(self.class) &&
          name == other.name &&
          records == other.records &&
          value == other.value
      end
      alias eql? ==
    end
  end
end
