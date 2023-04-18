# frozen_string_literal: true

class OrderItem < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  belongs_to :order

  validates :quantity, presence: true

  scope :persisted, -> { where.not(id: nil) }

  def variant
    @variant ||= Variant.includes(:product).find_by(id: variant_id)
  end

  # TO DO: should we associate the adjustment to the item or handle this thru variant and
  # remove the stock_adjustment from order_item???
  def adjust_stock(user_id)
    variant.sold(quantity:, user_id:)
  end

  def invoice_display_details
    "#{variant.invoice_display_details} - Quanity: #{quantity}"
  end

  def display_name
    variant.display_with_product_details
  end

  def display_retail_amount_per_unit
    variant.display_retail_price
  end

  def display_retail_amount_per_unit_including_tax
    variant.display_total_retail_price_including_tax
  end

  def display_retail_amount
    number_to_currency(format('%.2f', (retail_price_in_cents_as_float.to_f / 100))) unless retail_price_in_cents_as_float.nil?
  end

  def display_retail_amount_tax
    number_to_currency(format('%.2f', (retail_price_tax_amount_in_cents_as_float.to_f / 100))) unless retail_price_tax_amount_in_cents_as_float.nil?
  end

  def display_total_retail_amount
    number_to_currency(format('%.2f', (total_retail_price_in_cents_as_float.to_f / 100))) unless total_retail_price_in_cents_as_float.nil?
  end

  def total_retail_price_in_cents_as_float
    variant.total_retail_price_in_cents_as_float * quantity if variant.present? && quantity.present?
  end

  def retail_price_tax_amount_in_cents_as_float
    variant.retail_price_tax_amount_in_cents_as_float * quantity if variant.present? && quantity.present?
  end

  def retail_price_in_cents_as_float
    variant.retail_price_in_cents_as_float * quantity if variant.present? && quantity.present?
  end
end
