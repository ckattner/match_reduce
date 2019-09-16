# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'matrix/key_value_pair'

module MatchReduce
  module HashMath
    # A Matrix allows you to build up a hash of key and values, then it will generate the
    # product of all values.
    class Matrix
      extend Forwardable
      include Enumerable

      def_delegators :pair_products, :each

      def initialize
        @pairs_by_key = {}

        freeze
      end

      def add_each(key, vals)
        tap { kvp(key).add_each(vals) }
      end

      def add(key, val)
        tap { kvp(key).add(val) }
      end

      private

      attr_reader :pairs_by_key

      def kvp(key)
        pairs_by_key[key] ||= KeyValuePair.new(key)
      end

      def pair_products
        pair_groups = pairs_by_key.values.map(&:pairs)

        products = pair_groups.inject(pair_groups.shift) { |memo, f| memo.product(f) }
                              &.map { |f| f.is_a?(KeyValuePair::Pair) ? [f] : f.flatten } || []

        products.map { |pairs| recombine(pairs) }
      end

      def recombine(pairs)
        pairs.each_with_object({}) { |p, memo| memo[p.key] = p.value }
      end
    end
  end
end
