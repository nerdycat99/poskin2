# frozen_string_literal: true

require 'csv'

module Reports
  class SalesReportItem
    include ActiveModel::Attributes
    include ApplicationHelper

    attribute :date, :string
    attribute :order_ref, :string
    attribute :description, :string
    attribute :quantity, :string
    attribute :amounts, :string
    attribute :amount_paid, :string

    def populate_from(item, additional_row=nil, summary_value=nil)
      if item&.class&.name == 'Order' && !additional_row
        self.date = item.display_date
        self.order_ref = item.id
        self.amounts = item.number_of_items == 1 ? item.display_order_price_total_including_tax : nil
        self.description = item.number_of_items > 1 ? nil : item.order_items&.first&.display_name
        self.quantity = item.number_of_items > 1 ? nil : item.number_of_items
        self.amount_paid = item.number_of_items > 1 || (item.has_delivery_charges? || item.discounted?) ? nil : item.display_order_price_total_including_tax
      elsif !additional_row # these are order items, order was for more than 1 item
        self.date = nil
        self.order_ref = nil
        self.amounts = item.display_retail_amount_per_unit_including_tax
        self.description = item.display_name
        self.quantity = item.quantity
        self.amount_paid = nil
      elsif additional_row
        case additional_row
        when :delivery
          self.date = nil
          self.order_ref = nil
          self.amounts = item.display_delivery_amount
          self.description = 'DELIVERY'
          self.quantity = nil
          self.amount_paid = nil
        when :discount
          self.date = nil
          self.order_ref = nil
          self.amounts = item.display_discount_amount
          self.description = 'DISCOUNT'
          self.quantity = nil
          self.amount_paid = nil
        when :total
          self.date = nil
          self.order_ref = nil
          self.amounts = nil
          self.description = 'TOTAL'
          self.quantity = item.number_of_items
          self.amount_paid = item.display_order_price_total_including_tax_with_delivery_or_discount
        when :summary
          self.date = 'SUMMARY TOTAL'
          self.order_ref = nil
          self.amounts = nil
          self.description = nil
          self.quantity = nil
          self.amount_paid = summary_value
        end
      end
    end
  end

  class Sales
    include ActionView::Helpers::NumberHelper

    attr_accessor :from_date, :string
    attr_accessor :to_date, :string
    attr_accessor :orders, :array
    attr_accessor :total_sales_amount, :string

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

    def additional_rows_for(order, additional_row_type, summary=nil)
      sales_report_item_additional_row = SalesReportItem.new
      sales_report_item_additional_row.populate_from(order, additional_row_type, summary)
      sales_report_item_additional_row
    end

    def orders_for_display
      total_sales_amount = 0
      orders_for_display = []
      filtered_orders = all_orders.where(:created_at => self.from_date.beginning_of_day..self.to_date.end_of_day)
      filtered_orders.each do |order|
        next if order.number_of_items < 1
        total_sales_amount += order.order_price_total_including_tax_with_delivery_or_discount
        sales_report_item = SalesReportItem.new
        sales_report_item.populate_from(order)
        orders_for_display << sales_report_item
        if order.number_of_items > 1
          order.order_items.each do |order_item|
            sales_report_item = SalesReportItem.new
            sales_report_item.populate_from(order_item)
            orders_for_display << sales_report_item
          end
          # when the order has more than 1 item we always add total and conditionally add delivery/discount
          if order.has_delivery_charges? || order.discounted?
            orders_for_display << additional_rows_for(order, :delivery) if order.has_delivery_charges?
            orders_for_display << additional_rows_for(order, :discount) if order.discounted?
            # add those additional_rows_for each
          end
          orders_for_display << additional_rows_for(order, :total)
          # always add additional_rows_for for the total
        else
          # when the order has only 1 item we conditionally  add discount/delivery and total
          if order.has_delivery_charges? || order.discounted?
            orders_for_display << additional_rows_for(order, :delivery) if order.has_delivery_charges?
            orders_for_display << additional_rows_for(order, :discount) if order.discounted?
            orders_for_display << additional_rows_for(order, :total)
          end
        end
      end
      # write the summary total line
      display_total_sales_amount = number_to_currency(format('%.2f', total_sales_amount.to_f)) unless total_sales_amount.nil?
      orders_for_display << additional_rows_for(nil, :summary, display_total_sales_amount)
      orders_for_display
    end
  end
end

