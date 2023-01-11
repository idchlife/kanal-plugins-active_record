# frozen_string_literal: true

require "active_record"

class PresentTableMigration < ActiveRecord::Migration[7.0]
  def initialize(name = self.class.name, version = "001_other_source")
    super
  end

  def up
    create_table :presents do |t|
      t.string :name, null: false

      t.timestamps
    end
  end

  def down
    drop_table :presents
  end
end
