# frozen_string_literal: true

require 'csv'

module Reports
  class Item
    include ActiveModel::Attributes
    include ApplicationHelper

    attribute :date, :string
    attribute :order_ref, :string
    attribute :sku_code, :string
    attribute :description, :string
    attribute :unit_amount_paid, :string
    attribute :quantity, :string
    attribute :total_amount_paid, :string

    def populate_from(item)
      self.date = item.order_display_date
      self.order_ref = item.order_id
      self.sku_code = item.sku_code
      self.description = item.display_name
      self.unit_amount_paid = item.display_retail_amount_per_unit_including_tax
      self.quantity = item.quantity
      self.total_amount_paid = item.display_total_retail_amount
    end
  end

  class ItemsSold
    attr_accessor :from_date, :string
    attr_accessor :to_date, :string
    attr_accessor :items_sold, :array

    def initialize
      self.from_date = all_orders.last.created_at.to_date
      self.to_date = all_orders.first.created_at.to_date
      self.items_sold = items_sold_display
    end

    def to_csv
      CSV.generate do |csv|
        csv << column_names.map{|column_name| column_name.titleize}
        items_sold.each do |item|
          csv << item.attributes.values_at(*column_names)
       end
      end
    end

    def filename
      "items-sold-report-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
    end

    def partial
      'reports/items_sold'
    end

    def update_with(params)
      self.from_date = params['from_date'].to_date
      self.to_date = params['to_date'].to_date
      self.items_sold = items_sold_display
    end

    def column_names
      Item.attribute_names
    end

    def all_orders
      @all_orders ||= Order.includes(order_items:[variant:[:product, :stock_adjustments, product_attributes_variants: [:product_attribute]]]).order(created_at: :desc)
    end

    def items_sold_display
      items_sold_display = []
      filtered_orders = all_orders.where(:created_at => self.from_date.beginning_of_day..self.to_date.end_of_day)
      filtered_orders.each do |order|
        next if order.number_of_items < 1
        order.order_items.each do |order_item|
          items_sold = Item.new
          items_sold.populate_from(order_item)
          items_sold_display << items_sold
        end
      end
      items_sold_display
    end
  end
end
