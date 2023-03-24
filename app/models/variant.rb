# frozen_string_literal: true

class Variant < ApplicationRecord
  has_and_belongs_to_many :product_attributes
  belongs_to :product
end
