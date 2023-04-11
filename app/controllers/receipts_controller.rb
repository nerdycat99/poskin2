# frozen_string_literal: true

class ReceiptsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!, only: %i[create show]

  def show
    # opens the receipt generated in the create method
    redirect_to '/receipt.pdf', allow_other_host: true
    # TO DO: generate with order number in create and clean up
  end

  def create
    receipt = order.receipts.new(receipt_params)

    return unless receipt.save

    # generate pdf using either the order details or those passed in via the manual process
    # pdf is stored in public from where it can be shown and printed in the show method
    pdf = if order.paid?
            ReceiptPdf.new(receipt:, order:)
          else
            ReceiptPdf.new(receipt:, order: nil)
          end
    pdf.render_file(Rails.public_path.join('receipt.pdf'))
    redirect_to order_path(order)
  end

  private

  def receipt_params
    params.require(:receipt).permit(:email_address, :item_one_name, :item_one_price_minus_tax, :item_two_name, :item_two_price_minus_tax,
                                    :item_three_name, :item_three_price_minus_tax, :item_four_name, :item_four_price_minus_tax)
  end

  def order
    @order ||= Order.find_by(id: params['order_id'])
  end

  # def invalid_params
  #   invalid_params = []
  #   # invalid_params << 'No referral content was provided.' if @content.blank?
  #   # invalid_params << 'Please provide a valid date.' if @date.blank?
  #   # invalid_params << 'User not found.' if current_user.blank?
  #   invalid_params
  # end

  # def content
  #   @content ||= params.dig('data', 'referrals')
  # end

  # def date_params
  #   params.dig('data', 'date')
  # end

  # def date
  #   date = convert_to_datetime(date_params) if date_params.present?
  #   @date = current_user&.datetime_in_users_timezone(date: date) if date.is_a?(Date) && current_user.present?
  # end
end
