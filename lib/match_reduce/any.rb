# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module MatchReduce
  # This class represents a wildcard.  Direct use of this class should be avoided, instead,
  # use the MatchReduce top-level-declared helper ANY constant.
  class Any
    SPECIAL_VALUE = [name, :any].freeze

    private_constant :SPECIAL_VALUE

    # Just be something totally unique.  Matching values cannot actually be an array, therefore
    # there should never be a chance of a collision if the hash of this object is based on
    # an array structure.
    def hash
      SPECIAL_VALUE.hash
    end

    def ==(other)
      other.instance_of?(self.class) && hash == other.hash
    end
    alias eql? ==
  end
end
