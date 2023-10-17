# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :available_reports, only: %i[index, show]
  before_action :selected_report, only: %i[show]

  def index
    @available_reports = available_reports
  end

  def show
    @report = report
    @view_model = report.view_model
    respond_to do |format|
      format.html
      format.csv { send_data @view_model.to_csv, filename: @view_model.filename}
      # format.csv { send_data Reports::Stock.to_csv, filename: "stock-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
    end
  end

  private

  def available_reports
    @available_reports ||= Report.available_reports
  end

  def report
    @report ||= Report.new(selected_report)
  end

  # selected report will be an array i.e. [:total_sales_summary, 'All sales summary']
  def selected_report
    @selected_report ||= available_reports[params['id'].to_i]
  end

  # def view_model
  #   case report.report_identifier
  #   when :total_stock_summary
  #     @view_model = Reports::Stock.new()
  #   end
  # end

  # def fetch_products
  #   @products ||= Product.includes(:supplier, variants: [:stock_adjustments, product_attributes_variants: [:product_attribute]]).all
  # end

  # def fetch_orders
  #   @orders ||= Order.includes(:order_items).all
  # end
end
