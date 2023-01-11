# frozen_string_literal: true

require "active_record"
require "active_record/schema"
require "kanal/core/plugins/plugin"
# require_relative "./overriden/version_suffix_migration_context"

module Kanal
  module Plugins
    module ActiveRecord
      class ActiveRecordPlugin < Kanal::Core::Plugins::Plugin
        attr_reader :connection_options

        @@migration_directories = []

        #
        # <Description>
        #
        # @param [Hash<String, Object>] connection_data <description>
        #
        def initialize(connection_options)
          super()

          @connection_options = connection_options

          clear_migration_directories
        end

        def name
          :active_record
        end

        #
        # @param [Kanal::Core::Core] core <description>
        #
        # @return [void] <description>
        #
        def setup(core)
          ::ActiveRecord::Base.establish_connection(**@connection_options)
        end

        #
        # Just in case
        #
        # @return [void] <description>
        #
        def clear_migration_directories
          @@migration_directories = {}
        end

        #
        # Add migrations directory to the list of migrations for specific project
        #
        # @param [String] dir <description>
        # @param [String] project_name name of project which will migrations belong to. NOT USED right now
        #
        # @return [void] <description>
        #
        def add_migrations_directory(dir_path, project_name: "default")
          raise "Directory path #{dir_path} for migrations does not exist!" unless Dir.exist? dir_path

          if !@@migration_directories.keys.include? project_name
            @@migration_directories[project_name] = []
          end

          return if @@migration_directories[project_name].include? dir_path

          @@migration_directories[project_name] << dir_path
        end

        #
        # Migrating all the added migrations
        #
        # @return [void] <description>
        #
        def migrate
          self.class.migrate
        end

        #
        # Check if ActiveRecord connected
        #
        # @return [Boolean] <description>
        #
        def self.connected?
          ::ActiveRecord::Base.connected?
        end

        #
        # This class method allows for Rakefile to access migration directories
        # NOTE: there maaaay be problems when somebody uses this plugin several times within one project, I guess?
        # Not sure this will be the use case in the future.
        #
        # @return [Array<String>] list of migration directories
        #
        def self.migration_directories
          @@migration_directories
        end

        def self.migrate
          @@migration_directories.each do |project_name, dir_path|
            # Kanal::Plugins::ActiveRecord::Overriden::VersionSuffixMigrationContext.new(
            #   project_name,
            ::ActiveRecord::MigrationContext.new(
              dir_path,
              ::ActiveRecord::Base.connection.schema_migration
            ).migrate
          end
        end
      end
    end
  end
end
