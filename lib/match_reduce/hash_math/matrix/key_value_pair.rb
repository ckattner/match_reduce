# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MatchReduce
  module HashMath
    class Matrix
      # A hash-like structure that allows you to gradually build up keys.
      class KeyValuePair
        Pair = Struct.new(:key, :value)

        attr_reader :key, :value

        def initialize(key)
          @key    = key
          @value  = Set.new

          freeze
        end

        def add_each(vals)
          tap { vals.each { |val| add(val) } }
        end

        def add(val)
          tap { value << val }
        end

        def pairs
          value.map { |value| Pair.new(key, value) }
        end
      end
    end
  end
end
