# frozen_string_literal: true

require 'csv'

module Reports
  class SupplierSalesReportItem
    include ActiveModel::Attributes
    include ApplicationHelper

    attribute :date, :string
    attribute :item_sold, :string
    attribute :sku_code, :string
    attribute :quantity, :string
    attribute :revenue_with_tax, :string
    attribute :revenue, :string
    attribute :gross_profit, :string
    attribute :net_profit, :string
    attribute :tax_due, :string
    attribute :cost_price_with_tax, :string

    def populate_from(item)
      self.date = item.display_date_of_sale
      self.item_sold = item.display_name
      self.sku_code = item.sku_code
      self.quantity = item.quantity
      self.revenue_with_tax = item.display_total_retail_amount
      self.revenue = item.display_retail_amount
      self.gross_profit = item.display_gross_profit
      self.tax_due = item.display_share_of_retail_tax_responsible_for
      self.net_profit = item.display_net_profit
      self.cost_price_with_tax = item.display_total_cost_price_amount
    end
  end

  class SupplierSales
    include ActionView::Helpers::NumberHelper

    attr_accessor :supplier_id, :string
    attr_accessor :from_date, :string
    attr_accessor :to_date, :string
    attr_accessor :orders, :array
    attr_accessor :total_cost_of_goods, :string
    attr_accessor :total_tax_due, :string
    attr_accessor :total_net_profit, :string

    def initialize
      self.from_date = all_orders.last.created_at.to_date
      self.to_date = all_orders.first.created_at.to_date
      self.orders = orders_for_display
    end

    def to_csv
      CSV.generate do |csv|
        csv << column_names.map{|column_name| column_name.titleize}
        orders.each do |order|
          csv << order.attributes.values_at(*column_names)
       end
      end
    end

    def filename
      "supplier-sales-report-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
    end

    def partial
      'reports/supplier_sales'
    end

    def update_with(params)
      self.supplier_id = params['supplier_id']
      self.from_date = params['from_date'].to_date
      self.to_date = params['to_date'].to_date
      self.orders = orders_for_display
    end

    def supplier
      @supplier ||= Supplier.find_by_id(self.supplier_id)
    end

    def column_names
      SupplierSalesReportItem.attribute_names
    end

    def all_orders
      @all_orders ||= Order.includes(order_items:[variant:[:product, :stock_adjustments, product_attributes_variants: [:product_attribute]]]).order(created_at: :desc)
    end

    def orders_for_display
      orders_for_display = []
      total_cost_of_goods = 0
      total_tax_due = 0
      total_net_profit = 0
      return orders_for_display unless supplier.present?
      filtered_orders ||= all_orders.where(:created_at => self.from_date.beginning_of_day..self.to_date.end_of_day)
      filtered_orders.each do |order|
        next if order.number_of_items < 1
        order.order_items.each do |order_item|
          if order_item.variant&.product&.supplier_id == supplier.id
            supplier_sales_report_item = SupplierSalesReportItem.new
            supplier_sales_report_item.populate_from(order_item)
            total_cost_of_goods += order_item.total_cost_price_in_cents_as_float
            total_tax_due += order_item.share_of_retail_tax_responsible_for_as_float
            total_net_profit += order_item.net_profit
            orders_for_display << supplier_sales_report_item
          end
        end
      end
      self.total_cost_of_goods = number_to_currency(format('%.2f', (total_cost_of_goods.to_f / 100))) unless total_cost_of_goods.nil?
      self.total_tax_due = number_to_currency(format('%.2f', (total_tax_due.to_f / 100))) unless total_tax_due.nil?
      self.total_net_profit = number_to_currency(format('%.2f', (total_net_profit.to_f / 100))) unless total_net_profit.nil?
      orders_for_display
    end
  end
end
