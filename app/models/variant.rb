# frozen_string_literal: true

class Variant < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  # TO DO: when we create a variant we should only create product_attributes_variants that are NOT blank.
  belongs_to :product
  has_many :product_attributes_variants, dependent: :destroy
  has_many :stock_adjustments

  enum price_calc_method: { via_cost_price: 0, via_retail_price: 1 }

  accepts_nested_attributes_for :product_attributes_variants

  validate :cost_or_retail_price_method

  before_save :clean_up_calculation_methods

  def self.search(target)
    return if target.blank?

    Variant.find_by(sku_code: target)
  end

  # when deleting Variants remove .product_attributes_variants (these contain a variant_id and a product_attribute_id
  # ProductAttributesVariant.where(variant_id: 19).delete_all

  def cost_or_retail_price_method
    return if use_product_details?

    # we need to skip this if all costs, markup and selection method are blank - means use the product level details
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
    self.cost_price = nil if price_calc_method == 'via_retail_price' || use_product_details?
    self.retail_price = nil if price_calc_method == 'via_cost_price' || use_product_details?
  end

  def selected_price_calc_method_id
    Variant.price_calc_methods[self.price_calc_method]
  end

  def generated_sku
    unique_sku
  end

  def calculated_via_cost_price?
    price_calc_method == 'via_cost_price' || (price_calc_method.blank? && !use_product_details?)
  end

  def markup_same_as_product?
    markup.blank? || markup == product.markup
  end

  def cost_price_same_as_product?
    cost_price.blank? || cost_price.to_f == product.cost_price_in_cents_as_float
  end

  def retail_price_same_as_product?
    retail_price.blank? || retail_price.to_f == product.retail_price_in_cents_as_float
  end

  def display_supplier_registered_for_sales_tax
    product.supplier_registered_for_sales_tax? ? 'Yes' : 'No'
  end

  def display_use_product_details
    use_product_details? ? 'Yes' : 'No'
  end

  def use_product_details?
    markup_same_as_product? && cost_price_same_as_product? && retail_price_same_as_product?
  end

  def use_product_details_drop_down_value
    !use_product_details? ? 1 : 0
  end

  def display_with_product_details
    "#{product.title.titleize}, #{display_characteristics}"
  end

  def display_title
    "#{product.title.titleize}"
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



  # DONE
  def display_cost_price
    number_to_currency(format('%.2f', (cost_price_in_cents_as_float / 100))) unless cost_price_in_cents_as_float.nil?
  end

  def display_cost_price_tax_amount
    number_to_currency(format('%.2f', (cost_price_tax_amount_in_cents_as_float / 100)))
  end

  def display_total_cost_price
    return product.display_total_cost_price if use_product_details?

    number_to_currency(format('%.2f', ((total_cost_price_in_cents_as_float) / 100))) unless total_cost_price_in_cents_as_float.nil?
  end

  # DONE
  def cost_price_tax_amount_in_cents_as_float
    if use_product_details?
      product.cost_price_tax_amount_in_cents_as_float
    else
      product.supplier_registered_for_sales_tax? ? cost_price_in_cents_as_float * tax_rate : 0.0
    end
  end

  # DONE
  def total_cost_price_in_cents_as_float
    if use_product_details?
      # product.cost_price_in_cents_as_float
      product.cost_price_total_in_cents_as_float
    else
      cost_price_in_cents_as_float + cost_price_tax_amount_in_cents_as_float
    end
  end

  # DONE
  # def cost_price_in_cents_as_float
  #   if use_product_details?
  #     product.cost_price_in_cents_as_float
  #   else
  #     cost_price.to_f
  #   end
  # end



  def cost_price_in_cents_as_float
    return product.cost_price_in_cents_as_float if use_product_details?

    if calculated_via_cost_price?
      cost_price.to_f
    else
      (retail_price_before_tax_in_cents_as_float / ((markup.to_f / 100.0) + 1)).round(0).to_f
    end
  end




  def retail_mark_up_amount_in_cents
    markup_percentage = markup ? markup.to_f / 100.0 : product.markup.to_f / 100.0
    cost_price_in_cents_as_float * markup_percentage
  end

  def tax_rate
    10.to_f / 100
  end

  def display_markup
    markup.present? ? "#{markup}%" : product.display_markup
  end

  # DONE
  def display_retail_mark_up_amount
    if use_product_details?
      product.display_retail_mark_up_amount
    else
      number_to_currency(format('%.2f', (retail_mark_up_amount_in_cents / 100))) unless retail_mark_up_amount_in_cents.nil?
    end
  end

  # DONE
  def display_profit_amount
    if use_product_details?
      product.display_profit_amount
    else
      number_to_currency(format('%.2f', (profit_amount_in_cents_as_float / 100))) unless profit_amount_in_cents_as_float.nil?
    end
  end

  # DONE
  def profit_amount_in_cents_as_float
    if use_product_details?
      profit_amount_in_cents_as_float
    else
      total_retail_price_in_cents_as_float - ((cost_price_in_cents_as_float + cost_price_tax_amount_in_cents_as_float) + share_of_retail_tax_responsible_for)
    end
  end

  # DONE
  def share_of_retail_tax_responsible_for
    return product.share_of_retail_tax_responsible_for if use_product_details?

    if product.supplier_registered_for_sales_tax?
      retail_price_tax_amount_in_cents_as_float - cost_price_tax_amount_in_cents_as_float
    else
      retail_price_tax_amount_in_cents_as_float
    end
  end

  # DONE
  def display_retail_sales_tax_liability_amount
    if use_product_details?
      product.display_retail_sales_tax_liability_amount
    else
      number_to_currency(format('%.2f', (share_of_retail_tax_responsible_for / 100))) unless share_of_retail_tax_responsible_for.nil?
    end
  end

  def display_total_retail_price_including_tax
    number_to_currency(format('%.2f', (total_retail_price_in_cents_as_float / 100))) unless total_retail_price_in_cents_as_float.nil?
  end

  # DONE
  def display_retail_price
    if use_product_details?
      product.display_retail_price
    else
      number_to_currency(format('%.2f', (retail_price_before_tax_in_cents_as_float / 100))) unless retail_price_before_tax_in_cents_as_float.nil?
    end
  end

  # DONE
  def display_retail_price_tax_amount
    if use_product_details?
      product.display_retail_price_tax_amount
    else
      number_to_currency(format('%.2f', (retail_price_tax_amount_in_cents_as_float / 100))) unless retail_price_tax_amount_in_cents_as_float.nil?
    end
  end

  # DONE
  def display_total_retail_price_including_tax
    if use_product_details?
      product.display_total_retail_price_including_tax
    else
      number_to_currency(format('%.2f', (total_retail_price_in_cents_as_float / 100))) unless total_retail_price_in_cents_as_float.nil?
    end
  end

  # DONE
  def retail_price_before_tax_in_cents_as_float
    return product.retail_price_before_tax_in_cents_as_float if use_product_details?

    if calculated_via_cost_price?
      retail_mark_up_amount_in_cents + cost_price_in_cents_as_float
    else
      (total_retail_price_in_cents_as_float / (1 + tax_rate)).round(0).to_f
    end
  end

  def retail_price_tax_amount_in_cents_as_float
    retail_price_before_tax_in_cents_as_float * tax_rate
  end

  # DONE
  # def total_retail_price_in_cents_as_float
  #   if use_product_details?
  #     product.total_retail_price_in_cents_as_float
  #   else
  #     retail_price_tax_amount_in_cents_as_float + retail_price_before_tax_in_cents_as_float
  #   end
  # end

  def total_retail_price_in_cents_as_float
    return product.total_retail_price_in_cents_as_float if use_product_details?

    if calculated_via_cost_price?
      cost_price.blank? ? (cost_price.to_f + (markup.to_f / 100.0).round(0)).to_f : retail_price_tax_amount_in_cents_as_float + retail_price_before_tax_in_cents_as_float
    else
      retail_price.to_f
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
