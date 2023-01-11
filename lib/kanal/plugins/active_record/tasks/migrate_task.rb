# frozen_string_literal: true

require "rake"
require "optparse"

require_relative "../active_record_plugin"

module Kanal
  module Plugins
    module ActiveRecord
      module Tasks
        class MigrateTask < ::Rake::TaskLib
          def initialize(name = :kanal)
            super()

            desc "Run migrations for Kanal plugin for ActiveRecord with all added migration directories. Use --yes to execute without y/n question."

            namespace name do
              namespace :active_record do
                task :migrate do |t, args|
                  options = {}
                  opts = OptionParser.new
                  opts.banner = "Usage: kanal:active_record:migrate [options]"
                  opts.on "-y", "--yes", "Don't ask for confirmation, just run migrations" do |y|
                    options[:yes] = y
                  end

                  args = opts.order! ARGV do
                  end
                  opts.parse!

                  execute_migration_task options[:yes]
                end
              end
            end
          end

          def execute_migration_task(yes = false)
            plugin = Kanal::Plugins::ActiveRecord::ActiveRecordPlugin

            unless plugin.connected?
              puts "ActiveRecord is not connected to the database.
Directive 🤖: You should execute this rake task with application or something that has
this plugin added and initialized (via setup method). In other words: how could I execute migrations,
if there is no connection to database? 😭"
              return
            end

            migration_dirs = plugin.migration_directories

            if migration_dirs.empty?
              puts "There are no migration directories for migrating. 👀
Try adding them yourself or add some plugins with them! 😉"
              return
            end

            unless yes
              puts "You are about to execute #{migration_dirs.size} directories with migrations to execute.
Are you sure you want to execute them?

Please enter y or Y as yes, other values will be considered as no"

              result = $stdin.gets.chomp

              if result != "y" && result != "Y"
                puts "Stopping migrations!"
                return
              end
            end


            puts "Executing migrations..."

            plugin.migrate

            puts "Done! 🥳"
          end
        end
      end
    end
  end
end
