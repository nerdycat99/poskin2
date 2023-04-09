# frozen_string_literal: true

class ProductAttribute < ApplicationRecord
  has_many :product_attributes_variants

  before_save :sanitize_value

  validate :unique_attribute?

  def self.atributes_for(type)
    ProductAttribute.where(name: type) if valid_attribute_types.include?(type)
  end

  def self.valid_attribute_types
    ProductAttributeType.all.map(&:name)
  end

  def unique_attribute?
    if ProductAttribute.where(name:, value: sanitize_value).any?
      errors.add :value, message: '- an attribute with this name already exists.'
      false
    else
      true
    end
  end

  def sanitize_value
    self.value = value.downcase
  end

  def display_value
    value.titleize
  end

  def in_use?
    product_attributes_variants.any?
  end
end
