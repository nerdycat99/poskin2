# frozen_string_literal: true

class ProductAttribute < ApplicationRecord
  has_many :product_attributes_variants
  # validates :name, presence: true, uniqueness: true
  validate :unique_attribute?
  # validates :value, presence: true, uniqueness: { scope: :name }

  before_save :sanitize_value

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
    self.value = value.upcase
  end

  def in_use?
    product_attributes_variants.any?
  end
end
