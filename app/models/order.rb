# frozen_string_literal: true

class Order < ApplicationRecord
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  has_many :order_items, dependent: :destroy
  has_many :receipts, dependent: :destroy # added temporarily so orders can be raised ad hoc

  # how to have this but make it optional
  # belongs_to :customer
  # accepts_nested_attributes_for :customer

  enum state: { raised: 0, paid: 1, failed: 2, refunded: 3, cancelled: 4 }
  enum payment_method: { credit_card: 0, debit_card: 1, other: 2 } # this needs to allow nil

  def self.display_payment_methods
    display_payment_methods = []
    Order.payment_methods.keys.map { |method| display_payment_methods << OpenStruct.new(name: method.humanize, display_name: method) }
    display_payment_methods
  end

  def customer
    @customer ||= Customer.find_by(id: customer_id)
  end

  def items
    @items ||= order_items.persisted
  end

  def paid?
    state == 'paid'
  end

  def manual_order?
    items.none?
  end

  def customer_details
    if customer.present?
      customer.email || "#{customer.first_name} #{customer.last_name}"
    elsif first_name && last_name
      email_address || "#{first_name} #{last_name}"
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

  def verification_check?
    order_price_total_including_tax_as_float == (order_price_total_as_float + order_tax_total_as_float)
  end

  def display_date
    convert_to_users_timezone(updated_at).to_fs(:long)
  end

  def display_order_price_total
    number_to_currency(format('%.2f', (order_price_total_as_float.to_f / 100))) unless order_price_total_as_float.nil?
  end

  def display_order_tax_total
    number_to_currency(format('%.2f', (order_tax_total_as_float.to_f / 100))) unless order_tax_total_as_float.nil?
  end

  def display_order_price_total_including_tax
    number_to_currency(format('%.2f', (order_price_total_including_tax_as_float.to_f / 100))) unless order_price_total_including_tax_as_float.nil?
  end
end
