# frozen_string_literal: true

require 'csv'

module Reports
  class StockReportItem
    include ActiveModel::Attributes
    include ApplicationHelper

    attribute :product, :string
    attribute :sku, :string
    attribute :description, :string
    attribute :quantity, :string
    attribute :cost_price, :string
    attribute :tax_amount, :string
    attribute :total_cost, :string
    attribute :retail_price, :string
    attribute :tax, :string
    attribute :total_retail, :string

    def populate_from(variant)
      self.product = variant.product.title
      self.sku = variant.sku_code
      self.description = variant.display_characteristics
      self.quantity = variant.stock_count
      self.cost_price = variant.display_cost_price
      self.tax_amount = variant.display_cost_price_tax_amount
      self.total_cost = variant.display_total_cost_price
      self.retail_price = variant.display_retail_price
      self.tax = variant.display_retail_price_tax_amount
      self.total_retail = variant.display_total_retail_price_including_tax
    end
  end

  class Stock
    def to_csv
      CSV.generate do |csv|
        csv << column_names.map{|column_name| column_name.titleize}
        variants.each do |variant|
          csv << variant.attributes.values_at(*column_names)
       end
      end
    end

    def filename
      "stock-report-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
    end

    def partial
      'reports/stock'
    end

    def column_names
      StockReportItem.attribute_names
    end

    def products
      @products ||= Product.includes(:supplier, variants: [:stock_adjustments, product_attributes_variants: [:product_attribute]]).all
    end

    def variants
      @variants = []
      products.each do |product|
        product.variants.each do |variant|
          stock_report_item = StockReportItem.new
          stock_report_item.populate_from(variant)
          @variants << stock_report_item
        end
      end
      @variants
    end

    # used for calculating the totals
    def total_product_quantity
      total_product_quantity = 0
      products.each do |product|
        total_product_quantity += product.variants.map(&:stock_count).compact.sum
      end
      total_product_quantity
    end

    # for each we must multiply by the number of items
    def total_cost_price
      total_cost_price = 0
      products.each do |product|
        total_cost_price += product.variants.map(&:total_stock_cost_price_without_tax_as_float).compact.sum
      end
      total_cost_price.nil? ? '$0.00' : helper.number_to_currency(format('%.2f', (total_cost_price / 100)))
    end

    def total_cost_price_tax_amount
      total_cost_price_tax_amount = 0
      products.each do |product|
        total_cost_price_tax_amount += product.variants.map(&:total_stock_cost_price_tax_amount_as_float).compact.sum
      end
      total_cost_price_tax_amount.nil? ? '$0.00' : helper.number_to_currency(format('%.2f', (total_cost_price_tax_amount / 100)))
    end

    def total_cost_price_including_tax
      total_cost_price_including_tax = 0
      products.each do |product|
        total_cost_price_including_tax += product.variants.map(&:total_stock_cost_price_including_tax_as_float).compact.sum
      end
      total_cost_price_including_tax.nil? ? '$0.00' : helper.number_to_currency(format('%.2f', (total_cost_price_including_tax / 100)))
    end

    def total_retail_price
      total_retail_price = 0
      products.each do |product|
        total_retail_price += product.variants.map(&:total_stock_retail_price_without_tax_as_float).compact.sum
      end
      total_retail_price.nil? ? '$0.00' : helper.number_to_currency(format('%.2f', (total_retail_price / 100)))
    end

    def total_retail_price_tax_amount
      total_retail_price_tax_amount = 0
      products.each do |product|
        total_retail_price_tax_amount += product.variants.map(&:total_stock_retail_price_tax_amount_as_float).compact.sum
      end
      total_retail_price_tax_amount.nil? ? '$0.00' : helper.number_to_currency(format('%.2f', (total_retail_price_tax_amount / 100)))
    end

    def total_retail_price_including_tax
      total_retail_price_including_tax = 0
      products.each do |product|
        total_retail_price_including_tax += product.variants.map(&:total_stock_retail_price_including_tax_as_float).compact.sum
      end
      total_retail_price_including_tax.nil? ? '$0.00' : helper.number_to_currency(format('%.2f', (total_retail_price_including_tax / 100)))
    end

    private

    def helper
      @helper ||= Class.new do
        include ActionView::Helpers::NumberHelper
      end.new
    end
  end
end
