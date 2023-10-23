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

    @view_model.update_with(filter_params) if filter_params
    session.delete(:filter)
    respond_to do |format|
      format.html
      format.csv { send_data @view_model.to_csv, filename: @view_model.filename}
    end
  end

  def update
    # the plan is to update the VM and have it available somehow in show, workaround for now
    session[:filter] = params['filter']
    redirect_to report_path(selected_report_id)
  end

  private

  def filter_params
    return params[:filter] if params[:filter]
    session[:filter]
  end

  def available_reports
    @available_reports ||= Report.available_reports
  end

  def report
    @report = Report.new(selected_report)
  end

  def selected_report_id
    params['id']
  end

  def selected_report
    @selected_report = available_reports[selected_report_id.to_i]
  end
end
