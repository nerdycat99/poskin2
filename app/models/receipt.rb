# frozen_string_literal: true

class Receipt < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  belongs_to :order

  def convert_string_amount_to_float(amount)
    (amount.gsub(/[^0-9.]/, '').to_f * 100).to_i
  end

  def order_reference_display
    order.id.to_s.rjust(5, '0')
  end

  def number_of_items
    if item_one_name.present && item_two_name.present && item_three_name.present && item_four_name.present
      4
    elsif item_one_name.present && item_two_name.present && item_three_name.present
      3
    elsif item_one_name.present && item_two_name.present
      2
    elsif item_one_name.present
      1
    else
      0
    end
  end

  def amount_one
    convert_string_amount_to_float(item_one_price_minus_tax) if item_one_price_minus_tax.present?
  end

  def amount_two
    convert_string_amount_to_float(item_two_price_minus_tax) if item_one_price_minus_tax.present?
  end

  def amount_three
    convert_string_amount_to_float(item_three_price_minus_tax) if item_one_price_minus_tax.present?
  end

  def amount_four
    convert_string_amount_to_float(item_four_price_minus_tax) if item_one_price_minus_tax.present?
  end

  def total_amount_as_float
    ((amount_one || 0) + (amount_two || 0) + (amount_three || 0) + (amount_four || 0)) || 0
  end

  def display_total_amount
    number_to_currency(format('%.2f', (total_amount_as_float.to_f / 100))) unless total_amount_as_float.nil?
  end

  def display_tax_amount
    number_to_currency(format('%.2f', (tax_amount.to_f / 100))) unless tax_amount.nil?
  end

  def display_total_amount_including_tax
    number_to_currency(format('%.2f', (total_amount_including_tax_as_float.to_f / 100))) unless total_amount_including_tax_as_float.nil?
  end

  def tax_amount
    total_amount_as_float * 0.1
  end

  def total_amount_including_tax_as_float
    total_amount_as_float + tax_amount
  end
end
