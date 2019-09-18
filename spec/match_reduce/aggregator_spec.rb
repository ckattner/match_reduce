# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe MatchReduce::Aggregator do
  describe '#initialize' do
    it 'sets patterns to at least one hash' do
      subject = described_class.new(name: :sig1)

      expect(subject.patterns).to eq([{}])
    end

    it 'patterns can be a hash' do
      subject = described_class.new(name: :sig1, patterns: { a: :b })

      expect(subject.patterns).to eq([{ 'a' => :b }])
    end

    it 'patterns can be an array of hashes' do
      subject = described_class.new(name: :sig1, patterns: [{ a: :b }])

      expect(subject.patterns).to eq([{ 'a' => :b }])
    end
  end
end
