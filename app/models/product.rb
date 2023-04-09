# frozen_string_literal: true

class Product < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  belongs_to :supplier
  has_and_belongs_to_many :category_tags
  has_many :variants, dependent: :destroy
  # accepts_nested_attributes_for :variants

  validates :accounting_code_id, :title, :description, :sku_code, :markup, presence: true
  validates :cost_price, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :publish, inclusion: { in: [true, false] }

  scope :without_variants, lambda {
    where(variants: nil)
  }

  scope :published, lambda {
    where(publish: true)
  }

  def self.search(target)
    return unless target.present?

    Product.without_variants.includes(:variants).find_by_sku_code(target) || Variant.search(target)
  end

  delegate :registered_for_sales_tax?, to: :supplier, prefix: true

  def display_notes
    (notes.presence || 'none listed')
  end

  def display_cost_price
    number_to_currency(format('%.2f', (cost_price.to_f / 100))) unless cost_price.nil?
  end

  def display_total_cost_price
    number_to_currency(format('%.2f', ((cost_price.to_f + cost_price_tax_amount_in_cents_as_float) / 100))) unless cost_price.nil?
  end

  # should be 0 if the supplier is not registered for tax
  def display_cost_price_tax_amount
    number_to_currency(format('%.2f', (cost_price_tax_amount_in_cents_as_float / 100)))
  end

  def display_retail_mark_up_amount
    number_to_currency(format('%.2f', (retail_mark_up_amount_in_cents / 100))) unless retail_mark_up_amount_in_cents.nil?
  end

  def display_retail_price
    number_to_currency(format('%.2f', (retail_price_in_cents_as_float / 100))) unless retail_price_in_cents_as_float.nil?
  end

  def display_retail_price_tax_amount
    number_to_currency(format('%.2f', (retail_price_tax_amount_in_cents_as_float / 100))) unless retail_price_tax_amount_in_cents_as_float.nil?
  end

  def display_total_retail_price_including_tax
    number_to_currency(format('%.2f', (total_retail_price_in_cents_as_float / 100))) unless total_retail_price_in_cents_as_float.nil?
  end

  def display_profit_amount
    number_to_currency(format('%.2f', (profit_amount_in_cents_as_float / 100))) unless profit_amount_in_cents_as_float.nil?
  end

  def display_retail_sales_tax_liability_amount
    number_to_currency(format('%.2f', (share_of_retail_tax_responsible_for / 100))) unless share_of_retail_tax_responsible_for.nil?
  end

  def cost_price_tax_amount_in_cents_as_float
    supplier_registered_for_sales_tax? ? cost_price * tax_rate : 0.0
  end

  def retail_mark_up_amount_in_cents
    (markup.to_f / 100.0) * cost_price.to_f unless markup.nil?
  end

  def retail_price_in_cents_as_float
    cost_price.to_f + retail_mark_up_amount_in_cents
  end

  def retail_price_tax_amount_in_cents_as_float
    retail_price_in_cents_as_float * tax_rate
  end

  def total_retail_price_in_cents_as_float
    retail_price_in_cents_as_float + retail_price_tax_amount_in_cents_as_float
  end

  def profit_amount_in_cents_as_float
    total_retail_price_in_cents_as_float - ((cost_price.to_f + cost_price_tax_amount_in_cents_as_float) + share_of_retail_tax_responsible_for)
  end

  def share_of_retail_tax_responsible_for
    if supplier_registered_for_sales_tax?
      retail_price_tax_amount_in_cents_as_float / 2
    else
      retail_price_tax_amount_in_cents_as_float
    end
  end

  def tax_rate
    10.to_f / 100
  end

  def cost_price_label
    supplier_registered_for_sales_tax? ? 'Cost price (excluding sales tax)' : 'Cost price'
  end

  def cost_price_header
    supplier_registered_for_sales_tax? ? 'Cost price' : 'Total Cost Price'
  end

  def display_retail_price
    number_to_currency(format('%.2f', (retail_price_in_cents_as_float / 100))) unless retail_price_in_cents_as_float.nil?
  end

  def display_markup
    "#{markup}%" if markup.present?
  end

  def display_published
    if publish.nil?
      'Yes'
    else
      publish ? 'Yes' : 'No'
    end
  end

  def generated_sku
    unique_sku
  end

  def display_sku
    variants.none? ? sku_code : nil
  end

  def stock_count
    variants.map(&:stock_count).compact.sum
  end

  def stock?
    stock_count.positive?
  end

  def been_sold?
    variants.includes(:stock_adjustments).map(&:been_sold?).compact.any?
  end

  def remove!
    Product.transaction do
      variants.includes(:product_attributes_variants).map(&:remove!)
      delete
    end
  end
end
