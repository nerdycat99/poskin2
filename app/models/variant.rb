# frozen_string_literal: true

class Variant < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  belongs_to :product
  has_many :product_attributes_variants, dependent: :destroy
  has_many :stock_adjustments

  accepts_nested_attributes_for :product_attributes_variants

  def self.search(target)
    return if target.blank?

    Variant.find_by(sku_code: target)
  end

  # when deleting Variants remove .product_attributes_variants (these contain a variant_id and a product_attribute_id
  # ProductAttributesVariant.where(variant_id: 19).delete_all

  # we need to add an attribute type when the user sets up attributes a variant can have like size, colour or artists code
  # when the user hits Add Attribute Values we shouls use this to control what they can add avlues for (eg: colour blue)

  def generated_sku
    unique_sku
  end

  def display_with_product_details
    "#{product.title.titleize}, #{display_characteristics}"
  end

  def invoice_display_details
    "#{product.title.titleize}, #{display_characteristics_for_invoice}"
  end

  def display_characteristics
    variant_characteristics.compact_blank.join(', ')
  end

  def display_characteristics_for_invoice
    variant_characteristics_for_invoice.compact_blank.join(', ')
  end

  def variant_characteristics
    tagged_attributes.map { |attr| "#{attr.name.titleize}: #{attr.value.titleize}" if attr.value.present? }
  end

  def variant_characteristics_for_invoice
    tagged_attributes.map { |attr| attr.value.titleize.to_s if attr.value.present? }
  end

  def tagged_attributes
    @tagged_attributes ||= product_attributes_variants.map(&:product_attribute)
  end

  def display_cost_price
    number_to_currency(format('%.2f', (cost_price.to_f / 100))) unless cost_price.nil?
  end

  def display_cost_price_tax_amount
    number_to_currency(format('%.2f', (cost_price_tax_amount_in_cents_as_float / 100)))
  end

  def display_total_cost_price
    if cost_price.nil?
      product.display_total_cost_price
    else
      number_to_currency(format('%.2f', ((total_cost_price_in_cents_as_float) / 100))) unless cost_price.nil?
    end
  end

  def cost_price_tax_amount_in_cents_as_float
    # looks wrong??????
    product.supplier_registered_for_sales_tax? ? cost_price.to_f * tax_rate : 0.0
  end

  def total_cost_price_in_cents_as_float
    cost_price.to_f + cost_price_tax_amount_in_cents_as_float
  end

  def cost_price_in_cents_as_float
    cost_price.to_f
  end

  def retail_mark_up_amount_in_cents
    markup_percentage = markup ? markup.to_f / 100.0 : product.markup.to_f / 100.0
    cost_price_in_cents_as_float * markup_percentage
  end

  def tax_rate
    10.to_f / 100
  end

  def display_markup
    "#{markup}%" if markup.present?
  end

  # TO DO: if the variant has it's own cost price then it should have it's own retail price??
  delegate :display_retail_price, to: :product

  delegate :display_retail_price_tax_amount, to: :product

  # delegate :display_total_retail_price_including_tax, to: :product

  delegate :retail_price_in_cents_as_float, to: :product

  # delegate :retail_price_tax_amount_in_cents_as_float, to: :product

  # delegate :total_retail_price_in_cents_as_float, to: :product



  def display_total_retail_price_including_tax
    number_to_currency(format('%.2f', (total_retail_price_in_cents_as_float / 100))) unless total_retail_price_in_cents_as_float.nil?
  end

  def retail_price_before_tax_in_cents_as_float
    retail_mark_up_amount_in_cents + cost_price_in_cents_as_float
  end

  def retail_price_tax_amount_in_cents_as_float
    retail_price_before_tax_in_cents_as_float * tax_rate
  end

  def total_retail_price_in_cents_as_float
    if cost_price? && cost_price != product.cost_price
      retail_price_tax_amount_in_cents_as_float + retail_price_before_tax_in_cents_as_float
    else
      product.total_retail_price_in_cents_as_float
    end
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
    adjustment = stock_adjustments.new(quantity:, adjustment_type: 'purchased', user_id:)
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
