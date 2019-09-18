# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MatchReduce
  # An aggregator is a group of patterns with a reducer that you wish to report on.
  class Aggregator
    acts_as_hashable

    attr_reader :group_keys,
                :name,
                :patterns,
                :reducer

    def initialize(name:, group_keys: [], patterns: [], reducer: nil)
      raise ArgumentError, 'name is required' if name.to_s.empty?

      @name       = name
      @group_keys = Array(group_keys)
      @patterns   = stringed_keys(ensure_not_empty(array(patterns)))
      @reducer    = reducer

      freeze
    end

    def keys
      patterns.flat_map(&:keys)
    end

    def reduce(memo, record, resolver)
      reducer ? reducer.call(memo, record, resolver) : memo
    end

    def grouped?
      !group_keys.empty?
    end

    private

    attr_reader :resolver

    def stringed_keys(hashes)
      hashes.map do |hash|
        hash.map { |k, v| [k.to_s, v] }.to_h
      end
    end

    def array(val)
      val.is_a?(Hash) ? [val] : Array(val)
    end

    def ensure_not_empty(val)
      val.empty? ? [{}] : val
    end
  end
end
