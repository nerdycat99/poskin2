# frozen_string_literal: true

class ProductAttributesVariant < ApplicationRecord
  belongs_to :product_attribute
  belongs_to :variant
end
