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

require_relative 'match_reduce/any'
require_relative 'match_reduce/aggregate'
require_relative 'match_reduce/index'
require_relative 'match_reduce/processor'

# Top-level namespace
module MatchReduce
  # Define the only instance as a helper constant for the entire library to share.
  # Technically it is not a singleton, but it does not have to be because it will still
  # provide equality where we need it: #hash, #eql?, and #==.  We are using this as a
  # special flag indicating: "match on any value".  So even if we were to instantiate
  # multiple Any objects, the point is moot.
  ANY = Any.new

  class << self
    def process(aggregates, records, resolver = Objectable.resolver)
      Processor.new(aggregates, resolver)
               .add_each(records)
               .results
    end
  end
end
