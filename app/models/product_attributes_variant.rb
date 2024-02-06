# frozen_string_literal: true

class ProductAttributesVariant < ApplicationRecord
  belongs_to :product_attribute
  belongs_to :variant

  # these are simply a mechanism to associate a particular product_attribute to a variant
  # product_attributes are essentially static items which the client can create and then associate with a variant
  # for example, colour: blue, and they will be used across multiple product_atributes_variants to say the variant
  # to which they are associated is blue.
  # product_atributes_variants can be removed BUT product_attributes should ONLY be removed if they are not being
  # used by any product_atributes_variant

  def type
    product_attribute.name
  end

  def description
    product_attribute.value
  end
end
