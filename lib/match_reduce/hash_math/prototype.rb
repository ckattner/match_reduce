# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MatchReduce
  module HashMath
    # A HashPrototype is a superset of all inputted hashes with unqiue properties:
    # - each key is a string
    # - each value is set to the base_value
    # You can then call #make! or #make to shape other hashes in the form of the prototype hash.
    class Prototype
      extend Forwardable

      class KeyOutOfBoundsError < StandardError; end

      def_delegators :prototype, :key?, :keys

      def initialize(hashes = [], base_value: nil)
        @prototype = derive(hashes, base_value)

        freeze
      end

      def make!(hash = {})
        make(hash, true)
      end

      def make(hash = {}, bound = false)
        (hash || {}).each_with_object(shallow_copy_prototype) do |(key, value), memo|
          key = key.to_s

          raise KeyOutOfBoundsError, "[#{key}] for: #{prototype.keys}" if not_key?(key) && bound
          next if not_key?(key)

          memo[key] = value
        end
      end

      private

      attr_reader :prototype

      def not_key?(key)
        !key?(key)
      end

      def shallow_copy_prototype
        {}.merge(prototype)
      end

      def derive(hashes, base_value)
        hashes.compact
              .map(&:keys)
              .flatten
              .each_with_object({}) { |key, memo| memo[key.to_s] = base_value }
      end
    end
  end
end
