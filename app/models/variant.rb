# frozen_string_literal: true

class Variant < ApplicationRecord
  include ApplicationHelper

  belongs_to :product
  has_many :product_attributes_variants
  accepts_nested_attributes_for :product_attributes_variants

  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def generated_sku
    unique_sku
  end

  def display_characteristics
    "#{size&.titleize} #{colour&.titleize}"
  end

  def variant_characteristics
    @variant_attribute_size , @variant_attribute_colour = [], []
    product_attributes_for_variant.each do | attribute |
      @variant_attribute_size << attribute if attribute.name == 'size'
      @variant_attribute_colour << attribute if attribute.name == 'colour'
    end
    # @variant_size ||= product_attributes_for_variant.select { |attr| attr.name == 'size' }.first
  end

  def size
    variant_characteristics
    @variant_attribute_size&.first&.value
  end

  def colour
    variant_characteristics
    @variant_attribute_colour&.first&.value
  end

  def product_attributes_for_variant
    @product_attributes_for_variant ||= product_attributes_variants.map{ |attributes| attributes.product_attribute }
  end
end
