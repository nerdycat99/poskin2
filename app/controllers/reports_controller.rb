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
    @selected_report = selected_report
    @products = products
  end

  private

  def available_reports
    @available_reports ||= report.available_reports
  end

  def report
    @report ||= Report.new
  end

  def selected_report
    @selected_report ||= available_reports[params['id'].to_i]
  end

  def products
    @products ||= Product.includes(:variants).all
  end
end
