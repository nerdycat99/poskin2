# frozen_string_literal: true

class Variant < ApplicationRecord
  include ApplicationHelper

  belongs_to :product
  has_many :product_attributes_variants, dependent: :destroy
  has_many :stock_adjustments

  accepts_nested_attributes_for :product_attributes_variants

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

  def attribute_types_set
    tagged_attributes.map(&:name)
  end

  def attribute_types_not_set
    ProductAttribute.valid_attribute_types - attribute_types_set
  end

  def stock_count
    stock_adjustments&.map(&:quantity_by_type)&.compact&.sum
  end

  def stock?
    stock_count.positive?
  end

  def been_sold?
    stock_adjustments.any?
  end

  def update_product_attributes(params)
    Variant.transaction do
      product_attributes_variants.delete_all
      params['product_attributes_variants_attributes'].each do |param|
        product_attributes_variants.create(product_attribute_id: param.second['product_attribute_id'])
      end
    end
  end

  def remove!
    Variant.transaction do
      product_attributes_variants&.delete_all
      delete
    end
  end
end
