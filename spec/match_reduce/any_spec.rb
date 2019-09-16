# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe MatchReduce::Any do
  describe '#hash' do
    it 'should be based on an array of the class name and the symbol :any' do
      expect(described_class.new.hash).to eq(['MatchReduce::Any', :any].hash)
    end
  end

  describe 'equality' do
    specify '#== should always be equal if the classes and hash are the same' do
      expect(described_class.new).to eq(described_class.new)

      expect(described_class.new).not_to eq(:any)
    end

    specify '#eql? should always be equal if the classes and hash are the same' do
      expect(described_class.new).to eql(described_class.new)

      expect(described_class.new).not_to eq(:any)
    end
  end
end
