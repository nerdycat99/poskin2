# frozen_string_literal: true

class Report
  # all attributes for every type of report query argumengt in here
  attr_accessor :id, :report_identifier, :report_title, :from_date, :to_date, :supplier_id

  def model_name
    ActiveModel::Name.new(self, nil, 'filter')
  end

  def to_key
    nil
  end

  def errors
    {}
  end

  def initialize(report)
    self.id = Report.available_reports.find_index(report)
    self.report_identifier = report[0]
    self.report_title = report[1]
  end

  # we pass id in to reports show and use that to determine the report to show, define them here
  def self.available_reports
    [
      [:total_stock_summary, 'All stock summary'],
      [:total_sales_summary, 'All sales summary'],
      [:total_sales_by_supplier, 'Sales by supplier']
    ]
  end

  def view_model
    case self.report_identifier
    when :total_stock_summary
      @view_model = Reports::Stock.new()
    when :total_sales_summary
      @view_model = Reports::Sales.new()
    when :total_sales_by_supplier
      @view_model = Reports::SupplierSales.new()
    end
  end
end
