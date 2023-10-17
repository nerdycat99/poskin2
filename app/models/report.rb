# frozen_string_literal: true

class Report
  attr_accessor :report_identifier, :report_title

  def initialize(report)
    self.report_identifier = report[0]
    self.report_title = report[1]
  end

  # we pass id in to reports show and use that to determine the report to show, define them here
  def self.available_reports
    [
      [:total_stock_summary, 'All stock summary'],
      [:total_sales_summary, 'All sales summary']
    ]
  end

  def view_model
    case self.report_identifier
    when :total_stock_summary
      @view_model = Reports::Stock.new()
    when :total_sales_summary
      @view_model = Reports::Sales.new()
    end
  end
end
