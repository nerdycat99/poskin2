# frozen_string_literal: true

class ProductAttribute < ApplicationRecord
  validates :name, presence: true

  def self.atributes_for(type)
    ProductAttribute.where(name: type) if valid_attribute_types.include?(type)
  end

  def self.valid_attribute_types
    ProductAttributeType.all.map(&:name)
  end
end
