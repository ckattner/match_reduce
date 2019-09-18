# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe MatchReduce::Index do
  def lookup_by_name(lookup)
    lookup.each_with_object({}) do |(pattern, aggregators), memo|
      memo[pattern] = aggregators.map(&:name)
    end
  end

  let(:base_value) { MatchReduce::ANY }

  describe '#initialization' do
    context 'constructing aggregators' do
      specify 'when all aggregators when empty' do
        subject = described_class.new

        expect(subject.aggregators).to eq([])
      end

      specify 'only each first unique aggregator name is kept' do
        aggregators = [
          { name: :sig3 },
          { name: :sig1 },
          { name: 'sig2' },
          { name: :sig2 },
          { name: :sig3 },
          { name: 'sig4' },
          { name: :sig4 },
          { name: :sig5 },
          { name: :sig5 }
        ]

        subject = described_class.new(aggregators)

        expect(subject.aggregators.length).to eq(7)
      end
    end

    context 'constructing lookup' do
      it 'creates lookup with aggregators' do
        subject = described_class.new

        expected = {}

        expect(subject.lookup).to eq(expected)
      end

      it 'creates lookup with aggregators that have no patterns' do
        aggregators = [
          { name: :sig3 },
          { name: :sig1 }
        ]

        subject = described_class.new(aggregators)

        expected = {
          {} => %i[sig3 sig1]
        }

        expect(lookup_by_name(subject.lookup)).to eq(expected)
      end

      it 'creates lookup with aggregators that have patterns and no patterns' do
        aggregators = [
          { name: :sig3 },
          { name: :sig1 },
          {
            name: :sig2,
            patterns: { 'a' => '1', 'b' => [nil], 'c' => :c }
          }
        ]

        subject = described_class.new(aggregators)

        expected = {
          { 'a' => base_value, 'b' => base_value, 'c' => base_value } => %i[sig3 sig1],
          { 'a' => '1', 'b' => [nil], 'c' => :c } => %i[sig2]
        }

        expect(lookup_by_name(subject.lookup)).to eq(expected)
      end
    end
  end
end
