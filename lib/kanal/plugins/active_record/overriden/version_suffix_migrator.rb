# frozen_string_literal: true

require "active_record"

module Kanal
  module Plugins
    module ActiveRecord
      module Overriden
        #
        # NOTE: NOT USED
        #
        class VersionSuffixMigrator < ::ActiveRecord::Migrator
          def initialize(direction, migrations, schema_migration, target_version = nil, version_suffix: nil)
            super(direction, migrations, schema_migration, target_version)

            @verson_suffix = version_suffix
          end

          def record_version_state_after_migrating(version)
            result = super

            "#{result}_#{@version_suffix}"
          end
        end
      end
    end
  end
end
