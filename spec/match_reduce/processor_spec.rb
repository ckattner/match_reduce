# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe MatchReduce::Processor do
  def make_sum_reducer(key)
    ->(memo, record) { memo.to_i + record[key].to_i }
  end

  let(:resolver) { Objectable.resolver }

  specify 'README example produces correct output' do
    snapshot = yaml_fixture('snapshots', 'teams_and_players.yaml')

    records     = snapshot['records']
    aggregates  = snapshot['aggregates'].map do |a|
      reducer = a['sum_reducer_key'] ? make_sum_reducer(a['sum_reducer_key']) : nil

      {
        name: a['name'],
        patterns: a['patterns'],
        reducer: reducer,
        group_keys: a['group_keys']
      }
    end

    subject = described_class.new(aggregates, resolver)

    results = subject.add_each(records).results

    expected = snapshot['results'].map do |r|
      MatchReduce::Processor::Result.new(r['name'], r['records'], r['value'])
    end

    results.each_with_index do |result, i|
      expect(result).to eq(expected[i])
    end
  end
end
