# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

class ProcessorMock
  def initialize(_aggregates, _resolver); end

  def add_each(_records)
    self
  end

  def results
    []
  end
end

describe MatchReduce do
  specify '#process should create new Processor, call add_each, then call results' do
    resolver    = nil
    aggregates  = []
    records     = []
    results     = []

    processor = ProcessorMock.new(aggregates, resolver)

    expect(MatchReduce::Processor).to receive(:new).with(aggregates, resolver).and_return(processor)
    expect(processor).to receive(:add_each).with(records).and_return(processor)
    expect(processor).to receive(:results).and_return(results)

    described_class.process(aggregates, records, resolver)
  end
end
