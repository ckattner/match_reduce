# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe MatchReduce::Processor::Result do
  let(:config) do
    {
      name: 'abc',
      records: [
        { something: :else }
      ],
      value: 123
    }
  end

  let(:args) { config.values }

  describe 'equality' do
    let(:object_a) { described_class.new(*args) }

    let(:object_b) { described_class.new(*args) }

    specify '#== compares class type and attributes' do
      expect(object_a).to eq(object_b)
    end

    specify '#== compares class type and attributes' do
      expect(object_a).to eql(object_b)
    end
  end

  specify '#hash is a computed hash of attributes' do
    subject = described_class.new(*args)

    expected = [
      config[:name], config[:records], config[:value]
    ].hash

    expect(subject.hash).to eq(expected)
  end
end
