# frozen_string_literal: true

class Variant < ApplicationRecord
  include ApplicationHelper

  belongs_to :product
  has_many :product_attributes_variants
  has_many :stock_adjustments

  accepts_nested_attributes_for :product_attributes_variants

  # validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # when deleting Variants remove .product_attributes_variants (these contain a variant_id and a product_attribute_id
  # ProductAttributesVariant.where(variant_id: 19).delete_all

  # we need to add an attribute type when the user sets up attributes a variant can have like size, colour or artists code
  # when the user hits Add Attribute Values we shouls use this to control what they can add avlues for (eg: colour blue)
  def generated_sku
    unique_sku
  end

  def display_characteristics
    variant_characteristics.compact_blank.join(', ')
  end

  def variant_characteristics
    tagged_attributes.map { |attr| "#{attr.name.titleize}: #{attr.value.titleize}" if attr.value.present? }
  end

  def tagged_attributes
    @tagged_attributes ||= product_attributes_variants.map(&:product_attribute)
  end

  def stock_count
    stock_adjustments.map(&:quantity_by_type).compact.sum
  end
end
