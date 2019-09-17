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
    return nil if key.to_s.empty?

    ->(memo, record, resolver) { memo.to_i + resolver.get(record, key).to_i }
  end

  def snapshot(snapshot)
    records     = snapshot.fetch('records', [])
    aggregates  = snapshot.fetch('aggregates', []).map do |a|
      {
        name: a['name'],
        patterns: a['patterns'],
        reducer: make_sum_reducer(a['sum_reducer_key']),
        group_keys: a['group_keys']
      }
    end

    results = snapshot.fetch('results', []).map do |r|
      MatchReduce::Processor::Result.new(r['name'], r['records'], r['value'])
    end

    OpenStruct.new(
      records: records,
      aggregates: aggregates,
      results: results
    )
  end

  let(:resolver) { Objectable.resolver }

  describe 'snapshots' do
    yaml_fixture_files('snapshots', 'processor').each_pair do |filename, snapshot_config|
      specify File.basename(filename) do
        example = snapshot(snapshot_config)

        subject = described_class.new(example.aggregates, resolver)

        results = subject.add_each(example.records).results

        err_msg = "invalid: #{example.results.length} results != #{example.aggregates.length} aggs"

        expect(example.results.length).to eq(example.aggregates.length), err_msg

        results.each_with_index do |result, i|
          expect(result).to eq(example.results[i])
        end
      end
    end
  end
end
