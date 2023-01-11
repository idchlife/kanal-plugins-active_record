# frozen_string_literal: true

require "active_record"
require_relative "./version_suffix_migrator"

module Kanal
  module Plugins
    module ActiveRecord
      module Overriden
        #
        # NOTE: NOT USED. CONSERVATED DUE TO THE USELESS WAY OF NAMED MIGRATIONS
        # IF PLUGIN WILL BE USED WITH RAILS (I suspect it will be common case scenario, because
        # it's not enough to create bots, it will be very often coupled with Rails for: admin, analytics,
        # bot + websites stack, with registration in both places, etc)
        #
        # Will not spend more time on this feature, if someone still
        # wants to utilize named migrations here - you are welcome, please fire up a PR,
        # we will look into it
        # 
        # Thanks to the craftsmanship in Redmine repository
        # I was able to learn how it creates named migration versions.
        # And now we can create our own strategy alike
        #
        class VersionSuffixMigrationContext < ::ActiveRecord::MigrationContext
          #
          # Overriden constructor to save version suffix
          #
          # @param [String] version_suffix <description>
          # @param [Array<String>, String] migration_paths <description>
          # @param [::ActiveRecord::SchemaMigration] schema_migration <description>
          #
          def initialize(version_suffix, migration_paths, schema_migration = ::ActiveRecord::SchemaMigration)
            @version_suffix = version_suffix
            super(migration_paths, schema_migration)
          end

          def up(target_version = nil, &block)
            selected_migrations = if block_given?
                                    migrations.select(&block)
                                  else
                                    migrations
                                  end

            Kanal::Plugins::ActiveRecord::Overriden::VersionSuffixMigrator.new(
              :up,
              selected_migrations,
              schema_migration,
              target_version,
              version_suffix: @version_suffix
            ).migrate
          end

          def migrations
            lst = super

            lst.map do |migration_proxy|
              migration_proxy.version = "#{migration_proxy.version}_#{@version_suffix}"

              migration_proxy
            end
          end

          def get_all_versions
            if schema_migration.table_exists?
              schema_migration.all_versions.filter do |v|
                v.include? @version_suffix
              end.map do |v|
                Integer(v.sub!(@version_suffix, ""), 10)
              end
            else
              []
            end
          end
        end
      end
    end
  end
end
