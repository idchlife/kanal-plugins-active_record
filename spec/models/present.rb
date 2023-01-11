# frozen_string_literal: true

require "active_record"

class Present < ActiveRecord::Base
  self.table_name = :products
end
