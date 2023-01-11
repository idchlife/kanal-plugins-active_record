# frozen_string_literal: true

require "fileutils"
require "kanal"
require "kanal/plugins/active_record/active_record_plugin"
require_relative "../../../models/product"
require_relative "../../../models/present"

DATABASE_PATH = File.join __dir__, "../../../tmp/database.sqlite"

RSpec.describe Kanal::Plugins::ActiveRecord::ActiveRecordPlugin do
  before :each do
    FileUtils.rm_f DATABASE_PATH
  end

  it "establishes connection to sqlite database and executes migration" do
    core = Kanal::Core::Core.new

    plugin = Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.new(
      adapter: "sqlite3",
      database: DATABASE_PATH
    )
    plugin.add_migrations_directory File.join(__dir__, "../../../migrations")

    core.register_plugin plugin # .setup called, connection should be established

    Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.migrate

    expect(File.exist?(DATABASE_PATH)).to eq true
  end

  it "accepts migrations from different directories" do
    core = Kanal::Core::Core.new

    plugin = Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.new(
      adapter: "sqlite3",
      database: DATABASE_PATH
    )
    plugin.add_migrations_directory File.join(__dir__, "../../../migrations_other_source")
    plugin.add_migrations_directory File.join(__dir__, "../../../migrations")

    core.register_plugin plugin # .setup called, connection should be established

    Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.migrate

    expect(File.exist?(DATABASE_PATH)).to eq true

    expect(Product.table_exists?).to eq true
    expect(Present.table_exists?).to eq true
  end

  it "situatuion: user added one migration, migrated, after some time added plugin with OLDER migration by timestamp. we need this to work" do
    core = Kanal::Core::Core.new

    plugin = Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.new(
      adapter: "sqlite3",
      database: DATABASE_PATH
    )
    # Newer migration
    plugin.add_migrations_directory File.join(__dir__, "../../../migrations_other_source")

    core.register_plugin plugin # .setup called, connection should be established

    Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.migrate

    # Older migration
    plugin.add_migrations_directory File.join(__dir__, "../../../migrations")

    Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.migrate

    expect(File.exist?(DATABASE_PATH)).to eq true

    expect(Product.table_exists?).to eq true
    expect(Present.table_exists?).to eq true
  end

  it "checking whether models are working properly with database" do
    core = Kanal::Core::Core.new

    plugin = Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.new(
      adapter: "sqlite3",
      database: DATABASE_PATH
    )
    plugin.add_migrations_directory File.join(__dir__, "../../../migrations_other_source")
    plugin.add_migrations_directory File.join(__dir__, "../../../migrations")

    core.register_plugin plugin # .setup called, connection should be established

    Kanal::Plugins::ActiveRecord::ActiveRecordPlugin.migrate

    product = Product.create name: "Turnip", price: 345

    product = Product.find_by name: "Turnip"

    expect(product).not_to be nil

    expect(product).to be_an_instance_of Product

    expect(product.price).to eq 345
  end
end
