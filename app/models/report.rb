# frozen_string_literal: true

class Report
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  def available_reports
    [
      [:total_stock_summary, 'All stock summary'],
      [:total_sales_summary, 'All sales summary']
    ]
  end

  def total_product_quantity(products)
    total_product_quantity = 0
    products.each do |product|
      total_product_quantity += product.variants.map(&:stock_count).compact.sum
    end
    total_product_quantity
  end

  # for each we must multiply by the number of items
  def total_cost_price(products)
    total_cost_price = 0
    products.each do |product|
      total_cost_price += product.variants.map(&:total_stock_cost_price_without_tax_as_float).compact.sum
    end
    total_cost_price.nil? ? '$0.00' : number_to_currency(format('%.2f', (total_cost_price / 100)))
  end

  def total_cost_price_display(products)

  end

  def total_cost_price_tax_amount(products)
    total_cost_price_tax_amount = 0
    products.each do |product|
      total_cost_price_tax_amount += product.variants.map(&:total_stock_cost_price_tax_amount_as_float).compact.sum
    end
    total_cost_price_tax_amount.nil? ? '$0.00' : number_to_currency(format('%.2f', (total_cost_price_tax_amount / 100)))
  end

  def total_cost_price_including_tax(products)
    total_cost_price_including_tax = 0
    products.each do |product|
      total_cost_price_including_tax += product.variants.map(&:total_stock_cost_price_including_tax_as_float).compact.sum
    end
    total_cost_price_including_tax.nil? ? '$0.00' : number_to_currency(format('%.2f', (total_cost_price_including_tax / 100)))
  end

  def total_retail_price(products)
    total_retail_price = 0
    products.each do |product|
      total_retail_price += product.variants.map(&:total_stock_retail_price_without_tax_as_float).compact.sum
    end
    total_retail_price.nil? ? '$0.00' : number_to_currency(format('%.2f', (total_retail_price / 100)))
  end

  def total_retail_price_tax_amount(products)
    total_retail_price_tax_amount = 0
    products.each do |product|
      total_retail_price_tax_amount += product.variants.map(&:total_stock_retail_price_tax_amount_as_float).compact.sum
    end
    total_retail_price_tax_amount.nil? ? '$0.00' : number_to_currency(format('%.2f', (total_retail_price_tax_amount / 100)))
  end

  def total_retail_price_including_tax(products)
    total_retail_price_including_tax = 0
    products.each do |product|
      total_retail_price_including_tax += product.variants.map(&:total_stock_retail_price_including_tax_as_float).compact.sum
    end
    total_retail_price_including_tax.nil? ? '$0.00' : number_to_currency(format('%.2f', (total_retail_price_including_tax / 100)))
  end

end


