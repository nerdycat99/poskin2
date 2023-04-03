# frozen_string_literal: true

class ProductAttributesVariant < ApplicationRecord
  belongs_to :product_attribute
  belongs_to :variant

  def type
    product_attribute.name
  end

  def description
    product_attribute.value
  end
end
