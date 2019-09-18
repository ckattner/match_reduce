# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'acts_as_hashable'
require 'hash_math'
require 'objectable'

require_relative 'match_reduce/aggregator'
require_relative 'match_reduce/index'
require_relative 'match_reduce/processor'

# Top-level namespace
module MatchReduce
  # Something unique which will represent "match on all values".  This is used as the base
  # value for all pattern keys.
  ANY = :__ANY__

  class << self
    def process(aggregators, records, resolver: Objectable.resolver, any: ANY)
      Processor.new(aggregators, resolver: resolver, any: any)
               .add_each(records)
               .results
    end
  end
end
