# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

namespace :wa do
  desc 'Regenerate spec/fixtures/webawesome-enums.json from a Web Awesome version (e.g. rake wa:manifest[3.10.0])'
  task :manifest, [:version] do |_t, args|
    version = args[:version] or abort 'Usage: rake wa:manifest[3.10.0]'
    ruby "script/update_wa_manifest.rb #{version}"
  end
end

task default: %i[spec rubocop]
