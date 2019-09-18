# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

class ProcessorMock
  def initialize(_aggregators, resolver: nil, any: nil); end

  def add_each(_records)
    self
  end

  def results
    []
  end
end

describe MatchReduce do
  specify '#process should create new Processor, call add_each, then call results' do
    resolver    = 1
    any         = 2
    aggregators = 3
    records = 4

    processor = ProcessorMock.new(aggregators, resolver: resolver, any: any)

    expect(MatchReduce::Processor).to receive(:new).with(aggregators, resolver: resolver, any: any)
                                                   .and_return(processor)

    expect(processor).to receive(:add_each).with(records).and_return(processor)

    expect(processor).to receive(:results)

    described_class.process(aggregators, records, resolver: resolver, any: any)
  end
end
