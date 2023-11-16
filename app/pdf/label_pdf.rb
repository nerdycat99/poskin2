# frozen_string_literal: true

require 'barby'
# require 'barby/barcode/code_39'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
# require 'barby/outputter/prawn_outputter'

class LabelPdf < BasePdf
  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  TEXT_COLOUR = '000000'
  CELL_PADDING = [2, 4.5, 4.5, 5].freeze
  CELL_PADDING_PATIENT = [0, 5, 5, 0].freeze
  LABEL_WIDTH = 56.692913386
  LABEL_HEIGHT = 113.38582677

  def initialize(variant)
    @variant = variant
    super()
  end

  def content; end

  def item_description
    text "#{truncate(@variant.display_title, length: 23)}", size: 8.5, style: :bold, align: :center, color: TEXT_COLOUR
  end

  def sku_code
    text "#{@variant.barcode_sku}", size: 6.5, style: :light, align: :center, color: TEXT_COLOUR
  end

  def price
    text "#{@variant.display_total_retail_price_including_tax}", size: 8.5, style: :bold, align: :center, color: TEXT_COLOUR
  end

  private

  def barcode_image
    barcode = Barby::Code128.new @variant.sku_code
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    File.open("tmp/barcode.png", 'wb'){|f| f.write barcode.to_png }

    barcode = Rails.root.join("tmp/barcode.png")
    image barcode, width: 85, height: 29, position: :center, padding: 0
    # image barcode, width: 30, height: 11, position: :center
  rescue StandardError => e
    Rails.logger.error "barcode image error: #{e.message}"
  end

  def standard_header(_height = 100)
    move_down 2
    item_description
    move_down 0
    barcode_image
    move_down -1.5
    sku_code
    move_down 2.5
    price
    move_cursor_to bounds.height
  end
end
