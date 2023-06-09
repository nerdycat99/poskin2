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

  def old_method?
    changed_at = DateTime.new(2023, 4, 14).end_of_day - 20.minutes
    created_at <= changed_at
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

  def display_total_amount
    number_to_currency(format('%.2f', (total_amount_without_tax / 100))) if total_amount_without_tax.present?
    # number_to_currency(format('%.2f', (total_amount_as_float.to_f / 100))) if total_amount_as_float.present?
  end

  def display_tax_amount
    number_to_currency(format('%.2f', (tax_amount.to_f / 100))) if tax_amount.present?
  end

  def display_total_amount_including_tax
    # number_to_currency(format('%.2f', (total_amount_as_float.to_f / 100))) if total_amount_as_float.present?
    number_to_currency(format('%.2f', (total_amount_including_tax_as_float.to_f / 100))) if total_amount_including_tax_as_float.present?
  end

  # NB: although the prices on this model are called _minus_tax they are actually with GST
  # switched to make this easier to use
  def total_amount_without_tax
    if old_method?
      total_amount_as_float
    else
      total_amount_as_float / 1.1 #user entered amount including tax
    end
  end

  def total_amount_as_float
    ((amount_one || 0) + (amount_two || 0) + (amount_three || 0) + (amount_four || 0)) || 0
  end

  def tax_amount
    if old_method?
      total_amount_as_float * 0.1
    else
      total_amount_as_float - total_amount_without_tax #user entered amount including tax
    end
  end

  def total_amount_including_tax_as_float
    if old_method?
      total_amount_as_float + tax_amount
    else
      total_amount_as_float #user entered amount including tax
    end
  end
end
