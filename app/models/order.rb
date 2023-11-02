# frozen_string_literal: true

class Order < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  has_many :order_items, dependent: :destroy
  has_many :receipts, dependent: :destroy #added temporarily so orders can be raised ad hoc

  enum state: { raised: 0, paid: 1, failed: 2, refunded: 3, cancelled: 4 }
  enum payment_method: { credit_card: 0, debit_card: 1, other: 2 } # this needs to allow nil

  def self.display_payment_methods
    display_payment_methods = []
    Order.payment_methods.keys.map{|method| display_payment_methods << OpenStruct.new(name: method.humanize, display_name: method) }
    display_payment_methods
  end

  def customer
    @customer ||= Customer.find_by(id: customer_id)
  end

  def items
    # WE HAD TO CHANGE THIS AS IT CAUSED ISSUES CALCULATING PRICES IN REPORTS
    # (each item in report was hitting DB, so we upfront now chain ".where.not(id: nil)" into all_orders
    # means if we use this elsewhere we will need to perform where.not as above and NOT rely in persisted
    # @items ||= order_items.persisted
    @items ||= order_items
  end

  def paid?
    state == 'paid'
  end

  def manual_order?
    items.none?
  end

  def has_delivery_charges?
    delivery_amount.present? && delivery_amount > 0
  end

  def discounted?
    adjustment_amount.present? && adjustment_amount > 0
  end

  def customer_details
    if customer.present?
      customer.email_address || "#{customer.first_name} #{customer.last_name}"
    elsif first_name && last_name
      email_address || "#{first_name} #{last_name}"
    end
  end

  def customer_details_for_receipt
    if customer.present?
      customer.first_name && customer.last_name ? "#{customer.first_name} #{customer.last_name}" : "#{customer.email_address}"
    end
  end

  def number_of_items
    items.map(&:quantity).compact.sum
  end

  def order_price_total_as_float
    items.map(&:retail_price_in_cents_as_float).compact.sum
  end

  def order_tax_total_as_float
    items.map(&:retail_price_tax_amount_in_cents_as_float).compact.sum
  end

  def order_price_total_including_tax_as_float
    items.map(&:total_retail_price_in_cents_as_float).compact.sum
  end

  def discount_amount_as_float
    discount = adjustment_amount.present? ? (adjustment_amount.to_f / 100) * -1 : 0.0
  end

  def delivery_amount_as_float
    delivery_charge = delivery_amount.present? ? (delivery_amount.to_f / 100) : 0.0
  end

  def discount_or_delivery_amount_as_float
    delivery_amount_as_float + discount_amount_as_float
  end

  def order_price_total_including_tax_with_delivery_or_discount
    ((order_price_total_including_tax_as_float.to_f / 100) + delivery_amount_as_float) + discount_amount_as_float
  end

  def verification_check?
    order_price_total_including_tax_as_float == ( order_price_total_as_float + order_tax_total_as_float )
  end

  def display_order_price_total
    number_to_currency(format('%.2f', (order_price_total_as_float.to_f / 100))) unless order_price_total_as_float.nil?
  end

  def display_order_tax_total
    number_to_currency(format('%.2f', (order_tax_total_as_float.to_f / 100))) unless order_tax_total_as_float.nil?
  end

  def display_order_price_total_including_tax_with_delivery_or_discount
    number_to_currency(format('%.2f', order_price_total_including_tax_with_delivery_or_discount)) unless order_price_total_including_tax_with_delivery_or_discount.nil?
  end

  def display_delivery_amount
    number_to_currency(format('%.2f', delivery_amount_as_float)) unless delivery_amount_as_float.nil?
  end

  def display_discount_amount
    number_to_currency(format('%.2f', discount_amount_as_float)) unless discount_amount_as_float.nil?
  end

  def display_order_price_total_including_tax
    number_to_currency(format('%.2f', (order_price_total_including_tax_as_float.to_f / 100))) unless order_price_total_including_tax_as_float.nil?
  end

  def display_order_discount_or_delivery
    number_to_currency(format('%.2f', discount_or_delivery_amount_as_float)) unless discount_or_delivery_amount_as_float.nil?
  end

  def display_date
    convert_to_users_timezone(created_at).to_fs(:long)
  end
end
