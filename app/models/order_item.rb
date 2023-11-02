# frozen_string_literal: true

class OrderItem < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  belongs_to :order
  belongs_to :variant, inverse_of: :order_items, foreign_key: :variant_id

  validates :quantity, presence: true

  scope :persisted, -> { where.not(id: nil) }

  # TO DO: should we associate the adjustment to the item or handle this thru variant and
  # remove the stock_adjustment from order_item???
  def adjust_stock(user_id, order_id)
    variant.sold(quantity:, user_id:, order_id:)
  end

  def invoice_display_details
    "#{variant.invoice_display_details} - Quanity: #{quantity}"
  end

  def display_name
    variant&.display_with_product_details
  end

  def sku_code
    variant&.sku_code
  end

  def order_id
    order.id
  end

  def order_display_date
    order.display_date
  end

  def order_has_shipping_or_discount?
    order_discounted? || order_has_shipping?
  end

  def order_discounted?
    order.discounted?
  end

  def order_has_shipping?
    order.has_delivery_charges?
  end

  def percentage_of_order
    @percentage_of_order =  order.number_of_items > 1 ? retail_price_in_cents_as_float / order.order_price_total_as_float : 1
  end

  def delivery_charges_for_item
    order.delivery_amount * percentage_of_order
  end

  def display_date_of_sale
    order.display_date
  end

  def display_retail_amount_per_unit
    variant&.display_retail_price
  end

  def display_retail_amount_per_unit_including_tax
    variant&.display_total_retail_price_including_tax
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

  def display_cost_price_amount
    number_to_currency(format('%.2f', (cost_price_in_cents_as_float.to_f / 100))) unless cost_price_in_cents_as_float.nil?
  end

  def display_cost_price_amount_tax
    number_to_currency(format('%.2f', (cost_price_tax_amount_in_cents_as_float.to_f / 100))) unless cost_price_tax_amount_in_cents_as_float.nil?
  end

  def display_total_cost_price_amount
    number_to_currency(format('%.2f', (total_cost_price_in_cents_as_float.to_f / 100))) unless total_cost_price_in_cents_as_float.nil?
  end

  def display_gross_profit
    number_to_currency(format('%.2f', (gross_profit.to_f / 100))) unless gross_profit.nil?
  end

  def display_share_of_retail_tax_responsible_for
    number_to_currency(format('%.2f', (share_of_retail_tax_responsible_for_as_float.to_f / 100))) unless share_of_retail_tax_responsible_for_as_float.nil?
  end

  def display_net_profit
    number_to_currency(format('%.2f', (net_profit.to_f / 100))) unless net_profit.nil?
  end

  def total_retail_price_in_cents_as_float
    variant.total_retail_price_in_cents_as_float * quantity if variant.present? && quantity.present?
  end

  def retail_price_tax_amount_in_cents_as_float
    variant.retail_price_tax_amount_in_cents_as_float * quantity if variant.present? && quantity.present?
  end

  def retail_price_in_cents_as_float
    variant.retail_price_before_tax_in_cents_as_float * quantity if variant.present? && quantity.present?
  end

  def gross_profit
    total_retail_price_in_cents_as_float - total_cost_price_in_cents_as_float
  end

  def share_of_retail_tax_responsible_for_as_float
    variant.share_of_retail_tax_responsible_for * quantity if variant.present? && quantity.present?
  end

  def net_profit
    gross_profit - share_of_retail_tax_responsible_for_as_float
  end

  def total_cost_price_in_cents_as_float
    variant.total_cost_price_in_cents_as_float * quantity if variant.present? && quantity.present?
  end

  def cost_price_tax_amount_in_cents_as_float
    variant.cost_price_tax_amount_in_cents_as_float * quantity if variant.present? && quantity.present?
  end

  def cost_price_in_cents_as_float
    variant.cost_price_in_cents_as_float * quantity if variant.present? && quantity.present?
  end
end
