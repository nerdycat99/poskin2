# frozen_string_literal: true

class Product < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  belongs_to :supplier
  has_and_belongs_to_many :category_tags
  has_many :variants, dependent: :destroy
  # accepts_nested_attributes_for :variants

  enum price_calc_method: { via_cost_price: 0, via_retail_price: 1 }

  validates :accounting_code_id, :title, :description, :sku_code, presence: true
  validates :publish, inclusion: { in: [true, false] }
  validate :cost_or_retail_price_method

  before_save :clean_up_calculation_methods

  scope :without_variants, lambda {
    where(variants: nil)
  }

  scope :published, lambda {
    where(publish: true)
  }

  def self.search(target)
    return if target.blank?

    Product.without_variants.includes(:variants).find_by(sku_code: target) || Variant.search(target)
  end

  delegate :registered_for_sales_tax?, to: :supplier, prefix: true

  def selected_price_calc_method_id
    Product.price_calc_methods[self.price_calc_method]
  end

  def cost_or_retail_price_method
    if price_calc_method.blank?
      self.errors.add :price_calc_method, 'must be selected. You can calculate all costs and prices by either entering a cost or retail price'
    elsif price_calc_method == 'via_cost_price'
      self.errors.add :cost_price, 'must have a valid value' if cost_price.blank? || cost_price <= 0
      self.errors.add :markup, 'must have a valid value' if markup.blank?
    elsif price_calc_method == 'via_retail_price'
      self.errors.add :retail_price, 'must have a valid value' if retail_price.blank? || retail_price <= 0
      self.errors.add :markup, 'must have a valid value' if markup.blank?
    end
  end

  def clean_up_calculation_methods
    self.cost_price = nil if price_calc_method == 'via_retail_price'
    self.retail_price = nil if price_calc_method == 'via_cost_price'
  end

  def display_notes
    (notes.presence || 'none listed')
  end

  def calculated_via_cost_price?
    price_calc_method.blank? || price_calc_method == 'via_cost_price'
  end

  def calculated_via_retail_price?
    price_calc_method == 'via_retail_price'
  end

  def display_cost_price
    number_to_currency(format('%.2f', (cost_price_in_cents_as_float / 100))) unless cost_price_in_cents_as_float.nil?
  end

  def display_total_cost_price
    number_to_currency(format('%.2f', (cost_price_total_in_cents_as_float / 100))) unless cost_price_total_in_cents_as_float.nil?
  end

  def display_cost_price_tax_amount
    number_to_currency(format('%.2f', (cost_price_tax_amount_in_cents_as_float / 100)))
  end

  def display_retail_mark_up_amount
    number_to_currency(format('%.2f', (retail_mark_up_amount_in_cents / 100))) unless retail_mark_up_amount_in_cents.nil?
  end

  def display_retail_price
    number_to_currency(format('%.2f', (retail_price_before_tax_in_cents_as_float / 100))) unless retail_price_before_tax_in_cents_as_float.nil?
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

  def cost_price_in_cents_as_float
    if calculated_via_cost_price?
      cost_price.to_f
    else
      (retail_price_before_tax_in_cents_as_float / ((markup.to_f / 100.0) + 1)).round(0).to_f
    end
  end

  def cost_price_tax_amount_in_cents_as_float
    supplier_registered_for_sales_tax? ? cost_price_in_cents_as_float * tax_rate : 0.0
  end

  def cost_price_total_in_cents_as_float
    (cost_price_in_cents_as_float.round(0) + cost_price_tax_amount_in_cents_as_float.round(0)).to_f
  end

  def retail_mark_up_amount_in_cents
    if calculated_via_cost_price?
      cost_price_in_cents_as_float * (markup.to_f / 100.0)
    else
      retail_price_before_tax_in_cents_as_float - cost_price_in_cents_as_float
    end
  end

  # retail_price_in_cents_as_float is the retail price including tax
  def retail_price_in_cents_as_float
    if calculated_via_cost_price?
      if cost_price.blank?
        (cost_price.to_f + (markup.to_f / 100.0).round(0)).to_f
      else
        retail_price_before_tax_in_cents_as_float + retail_price_tax_amount_in_cents_as_float
        # (cost_price_in_cents_as_float&.round(0)&.+ retail_mark_up_amount_in_cents&.round(0))&.to_f
      end
    else
      # this is now teh amount that includes tax
      retail_price.to_f
    end
  end

  def retail_price_tax_amount_in_cents_as_float
    if calculated_via_cost_price?
      retail_price_before_tax_in_cents_as_float * tax_rate
    else
      total_retail_price_in_cents_as_float - retail_price_before_tax_in_cents_as_float
    end
  end

  def retail_price_before_tax_in_cents_as_float
    if calculated_via_cost_price?
      retail_mark_up_amount_in_cents + cost_price_in_cents_as_float
    else
      (total_retail_price_in_cents_as_float / (1 + tax_rate)).round(0).to_f
    end
  end

  def total_retail_price_in_cents_as_float
    retail_price_in_cents_as_float
    # retail_price_in_cents_as_float + retail_price_tax_amount_in_cents_as_float
  end

  def profit_amount_in_cents_as_float
    total_retail_price_in_cents_as_float - ((cost_price_in_cents_as_float + cost_price_tax_amount_in_cents_as_float) + share_of_retail_tax_responsible_for)
  end

  def share_of_retail_tax_responsible_for
    if supplier_registered_for_sales_tax?
      retail_price_tax_amount_in_cents_as_float - cost_price_tax_amount_in_cents_as_float
    else
      retail_price_tax_amount_in_cents_as_float
    end
  end

  def tax_rate
    10.to_f / 100.0
  end

  def cost_price_label
    supplier_registered_for_sales_tax? ? 'Cost price (excluding sales tax)' : 'Cost price'
  end

  def cost_price_header
    supplier_registered_for_sales_tax? ? 'Cost price' : 'Total Cost Price'
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
