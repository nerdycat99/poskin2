# frozen_string_literal: true

class ProductAttribute < ApplicationRecord
  has_and_belongs_to_many :variants
end
