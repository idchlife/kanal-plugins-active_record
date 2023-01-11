# frozen_string_literal: true

require "active_record"

class Product < ActiveRecord::Base
  self.table_name = :products
end
