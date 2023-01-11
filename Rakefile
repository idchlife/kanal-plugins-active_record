# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

require "active_record"
require_relative "./lib/kanal/plugins/active_record/tasks/migrate_task"

Kanal::Plugins::ActiveRecord::Tasks::MigrateTask.new