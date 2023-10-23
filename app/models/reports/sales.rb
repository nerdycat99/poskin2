# frozen_string_literal: true

require 'csv'

module Reports
  class SalesReportItem
    include ActiveModel::Attributes
    include ApplicationHelper

    attribute :date, :string
    attribute :order_ref, :string
    attribute :items, :string
    attribute :description, :string
    attribute :quantity, :string
    attribute :amount_paid, :string

    def populate_from(item)
      if item.class.name == 'Order'
        self.date = item.display_date
        self.order_ref = item.id
        self.items = item.number_of_items
        self.description = item.number_of_items > 1 ? nil : item.order_items&.first&.display_name
        self.quantity = nil
        self.amount_paid = item.number_of_items > 1 ? nil : item.display_order_price_total_including_tax_with_delivery_or_discount
      else # these are order items, order was for more than 1 item
        self.date = nil
        self.order_ref = nil
        self.items = nil
        self.description = item.display_name
        self.quantity = item.quantity
        self.amount_paid = item.display_retail_amount_per_unit_including_tax
      end
    end
  end

  class Sales
    attr_accessor :from_date, :string
    attr_accessor :to_date, :string
    attr_accessor :orders, :array

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
      "sales-report-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
    end

    def partial
      'reports/sales'
    end

    def update_with(params)
      self.from_date = params['from_date'].to_date
      self.to_date = params['to_date'].to_date
      self.orders = orders_for_display
    end

    def column_names
      SalesReportItem.attribute_names
    end

    def all_orders
      @all_orders ||= Order.includes(order_items:[variant:[:product, :stock_adjustments, product_attributes_variants: [:product_attribute]]]).order(created_at: :desc)
    end

    def orders_for_display
      orders_for_display = []
      filtered_orders = all_orders.where(:created_at => self.from_date.beginning_of_day..self.to_date.end_of_day)
      filtered_orders.each do |order|
        next if order.number_of_items < 1
        sales_report_item = SalesReportItem.new
        sales_report_item.populate_from(order)
        orders_for_display << sales_report_item
        if order.number_of_items > 1
          order.order_items.each do |order_item|
            sales_report_item = SalesReportItem.new
            sales_report_item.populate_from(order_item)
            orders_for_display << sales_report_item
          end
        end
      end
      orders_for_display
    end
  end
end
