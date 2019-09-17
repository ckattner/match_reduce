# frozen_string_literal: true

guard :rspec, cmd: 'DISABLE_SIMPLECOV=true bundle exec rspec --format=documentation' do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  watch(%r{^spec/fixtures/snapshots(.*)(\.yaml)$}) do |m|
    spec_file = m[1].split('/')[0...-1].join('/')

    File.join('spec', 'match_reduce', "#{spec_file}_spec.rb")
  end

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)
end
