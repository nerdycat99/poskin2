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

    def column_names
      SalesReportItem.attribute_names
    end

    def orders
      @orders = []
      Order.includes(:order_items).order(created_at: :desc).each do |order|
        next if order.number_of_items < 1
        sales_report_item = SalesReportItem.new
        sales_report_item.populate_from(order)
        @orders << sales_report_item
        if order.number_of_items > 1
          order.order_items.each do |order_item|
            sales_report_item = SalesReportItem.new
            sales_report_item.populate_from(order_item)
            @orders << sales_report_item
          end
        end
      end
      @orders
    end
  end
end
