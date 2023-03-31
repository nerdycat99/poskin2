# frozen_string_literal: true

class ProductAttribute < ApplicationRecord
  # has_and_belongs_to_many :variants # this feels wrong, these shoudl be associated to the prod_attr_variants
  VALID_ATTRIBUTE_TYPES = ProductAttributeType.all.map(&:name)

  def self.atributes_for(type)
    ProductAttribute.where(name: type) if VALID_ATTRIBUTE_TYPES.include?(type)
  end
end
