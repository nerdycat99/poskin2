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
    end
  end

  private

  def available_reports
    @available_reports ||= Report.available_reports
  end

  def report
    @report ||= Report.new(selected_report)
  end

  def selected_report
    @selected_report ||= available_reports[params['id'].to_i]
  end
end
