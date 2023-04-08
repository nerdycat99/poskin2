# frozen_string_literal: true

class Variant < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  belongs_to :product
  has_many :product_attributes_variants, dependent: :destroy
  has_many :stock_adjustments

  accepts_nested_attributes_for :product_attributes_variants

  def self.search(target)
    return unless target.present?

    Variant.find_by_sku_code(target)
  end

  # when deleting Variants remove .product_attributes_variants (these contain a variant_id and a product_attribute_id
  # ProductAttributesVariant.where(variant_id: 19).delete_all

  # we need to add an attribute type when the user sets up attributes a variant can have like size, colour or artists code
  # when the user hits Add Attribute Values we shouls use this to control what they can add avlues for (eg: colour blue)

  def generated_sku
    unique_sku
  end

  def display_with_product_details
    "#{product.title}, #{display_characteristics}"
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

  def display_cost_price
    number_to_currency(format('%.2f', (cost_price.to_f / 100))) unless cost_price.nil?
  end

  def display_markup
    "#{markup}%" if markup.present?
  end

  # TO DO: if the variant has it's own cost price then it should have it's own retail price??
  def display_retail_price
    product.display_retail_price
  end

  def display_retail_price_tax_amount
    product.display_retail_price_tax_amount
  end

  def display_total_retail_price_including_tax
    product.display_total_retail_price_including_tax
  end

  def retail_price_in_cents_as_float
    product.retail_price_in_cents_as_float
  end

  def retail_price_tax_amount_in_cents_as_float
    product.retail_price_tax_amount_in_cents_as_float
  end

  def total_retail_price_in_cents_as_float
    product.total_retail_price_in_cents_as_float
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

  def stock_for_order?(quantity)
    (stock_count - quantity.to_i) >= 0
  end

  def been_sold?
    stock_adjustments.any?
  end

  def sold(quantity:, user_id:)
    adjustment = stock_adjustments.new(quantity: quantity, adjustment_type: 'purchased', user_id: user_id)
    adjustment.save
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
