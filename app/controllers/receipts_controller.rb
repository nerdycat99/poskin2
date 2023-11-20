# frozen_string_literal: true

class ReceiptsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!, only: %i[new]

  def new
    respond_to do |format|
      format.pdf do
        pdf = ReceiptPdf.new(order:, include_customer_name: show_customer_name_on_receipt?)

        send_data pdf.render,
                  filename: "receipt_#{@order.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  private

  def show_customer_name_on_receipt?
    params['customer_name'].present? && params['customer_name'] == 'true'
  end

  def order
    @order ||= Order.find_by(id: params['order_id'])
  end
end
