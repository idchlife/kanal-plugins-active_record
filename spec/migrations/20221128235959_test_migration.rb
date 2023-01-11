# frozen_string_literal: true

require "active_record"

class TestMigration < ActiveRecord::Migration[7.0]
  def initialize(name = self.class.name, version = "001_default_source")
    super
  end

  def up
    create_table :products do |t|
      t.string :name, null: false
      t.integer :price, null: false

      t.timestamps
    end
  end

  def down
    drop_table :products
  end
end
