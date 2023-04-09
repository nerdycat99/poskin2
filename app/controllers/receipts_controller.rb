# frozen_string_literal: true

class ReceiptsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!, :content, :date, only: %i[create show]

  def create
    puts "****** SAVE RECEIPT"
    puts receipt_params.inspect
    receipt = order.receipts.new(receipt_params)
    if order.save
      redirect_to order_receipt_path(order, receipt, :format => 'pdf')
    end
  end

  def show
    receipt = Receipt.find_by(id: params['id'])
    puts "**** GEN RECEIPT"
    puts receipt.inspect

     pdf = ReceiptPdf.new(receipt)

    send_data pdf.render,
              filename: "receipt#{receipt.order.id}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
    pdf.render_file(Rails.root.join('public', "receipt#{receipt.order.id}.pdf"))

    # respond_to do |format|
    #   format.pdf do
    #     pdf = ReceiptPdf.new(receipt)

    #     send_data pdf.render,
    #               filename: "receipt#{receipt.order.id}.pdf",
    #               type: 'application/pdf',
    #               disposition: 'inline'
    #   end
    # end
    # target: "document_viewer"

    #     doc = Fineract::Document.find_by(parent_entity_type: "loans", parent_entity_id: @loan.id, id: @entity.id)
    # disposition = (params[:download].present?) ? 'attachment' : 'inline'
    # doc_view = interface.get_generic("loans/#{@loan.id}/documents/#{doc.id}/attachment")
    # send_data doc_view.body, filename: doc.file_name, type: doc.type, disposition: disposition
  end

  private

  def receipt_params
    params.require(:receipt).permit(:email_address, :item_one_name, :item_one_price_minus_tax, :item_two_name, :item_two_price_minus_tax, :item_three_name, :item_three_price_minus_tax, :item_four_name, :item_four_price_minus_tax)
  end

  def order
    @order ||= Order.find_by(id: params['order_id'])
  end

  def invalid_params
    invalid_params = []
    # invalid_params << 'No referral content was provided.' if @content.blank?
    # invalid_params << 'Please provide a valid date.' if @date.blank?
    # invalid_params << 'User not found.' if current_user.blank?
    invalid_params
  end

  def content
    @content ||= params.dig('data', 'referrals')
  end

  def date_params
    params.dig('data', 'date')
  end

  def date
    date = convert_to_datetime(date_params) if date_params.present?
    @date = current_user&.datetime_in_users_timezone(date: date) if date.is_a?(Date) && current_user.present?
  end
end