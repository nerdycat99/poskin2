# frozen_string_literal: true

class ReceiptPdf < BaseReceiptPdf
  include ApplicationHelper

  LARGE_TEXT_COLOUR = '000000'
  TEXT_LIGHT = '9F9F9F'
  LINE_COLOUR = 'D7D5D5'
  FONT_SIZE = 8
  LARGE_FONT_SIZE = 12
  CELL_PADDING = [2, 4.5, 4.5, 5].freeze
  CELL_PADDING_PATIENT = [0, 5, 5, 0].freeze

  def initialize(order:, include_customer_name: true)
    @order = order
    @include_customer_name = include_customer_name
    date = DateTime.now
    @date = date_formatter(date, '%a %d/%m/%Y %H:%M:%S')
    # @date = date_formatter(date, '%A %e %B %Y')
    super()
  end

  def header
    standard_header
  end

  def content
    move_down 60
    company_info
    move_down 60
    transaction_timestamp
    move_down 10
    transaction_reference
    if @include_customer_name  && @order.customer.present?
      move_down 10
      customer_details
      move_down 30
      transaction_details
    else
      move_down 30
      transaction_details
    end
    if @order.notes.present?
      move_down 40
      notes
    end
  end

  def company_info
    text 'Shop 7', size: 14, style: :light, align: :center, color: BOX_TEXT_COLOUR
    move_down 5
    text '573 Military Road', size: 14, style: :light, align: :center, color: BOX_TEXT_COLOUR
    move_down 5
    text 'Mosman, 2088, NSW', size: 14, style: :light, align: :center, color: BOX_TEXT_COLOUR
    move_down 20
    text 'ABN 36 674 780 628', size: 12, style: :normal, align: :center, color: BOX_TEXT_COLOUR
    move_down 5
    text 'www.australian-glass.com.au', size: 14, style: :bold, align: :center, color: BOX_TEXT_COLOUR
  end

  def transaction_timestamp
    text @date, size: 12, style: :light, align: :center, color: BOX_TEXT_COLOUR
  end

  def transaction_reference
    text "Order Reference: #{@order.reference_display}", size: 12, style: :light, align: :center, color: BOX_TEXT_COLOUR
  end

  def customer_details
    text "Customer: #{@order.customer_details_for_receipt}", size: 12, style: :normal, align: :center, color: BOX_TEXT_COLOUR
  end

  def notes
    text "Notes: #{@order.notes}", size: 10, style: :light, align: :center, color: BOX_TEXT_COLOUR
  end

  def transaction_details
    if @order.present?
      transaction_details_for_order
    else
      transaction_details_for_receipt
    end
  end

  def transaction_details_for_order
    @order.order_items.each do |item|
      indent(90, 0) do
        text item.invoice_display_details, size: 12, style: :normal, color: BOX_TEXT_COLOUR
        move_up 12
        text item.display_retail_amount_per_unit, size: 12, style: :normal, color: BOX_TEXT_COLOUR, align: :right
      end
      move_down 10
    end
    move_down 20
    indent(90, 0) do
      text 'Total Amount', size: 12, style: :bold, color: BOX_TEXT_COLOUR
      move_up 12
      text @order.display_order_price_total, size: 12, style: :bold, color: BOX_TEXT_COLOUR, align: :right
    end
    move_down 10
    indent(90, 0) do
      text 'Sales Tax', size: 12, style: :bold, color: BOX_TEXT_COLOUR
      move_up 12
      text @order.display_order_tax_total, size: 12, style: :bold, color: BOX_TEXT_COLOUR, align: :right
    end

    move_down 10
    indent(90, 0) do
      text 'Total Amount (including Tax)', size: 12, style: :bold, color: BOX_TEXT_COLOUR
      move_up 12
      text @order.display_order_price_total_including_tax, size: 12, style: :bold, color: BOX_TEXT_COLOUR, align: :right
    end
  end

  private

  def header_logo(width:, image:)
    logo = Rails.root.join("app/assets/images/#{image}.png")
    image logo, width:, position: :center
  rescue StandardError => e
    Rails.logger.error "header image error: #{e.message}"
  end

  def standard_header(_height = 100)
    logo_width = 300

    move_down 0

    # indent(145, 0) do
      header_logo(width: logo_width, image: 'ag_logo')
      move_cursor_to bounds.height
    # end
  end
end
