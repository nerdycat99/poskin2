# frozen_string_literal: true

class ProductAttributeType < ApplicationRecord
  validates :name, presence: true

  before_save :parameterize_name
  after_create :blank_product_attribute_for_type

  def parameterize_name
    self.name = name.parameterize(separator: '_')
  end

  def blank_product_attribute_for_type
    ProductAttribute.create(name:, value: '')
  end
end
