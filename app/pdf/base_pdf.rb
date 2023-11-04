# frozen_string_literal: true

require 'open-uri'

class BasePdf
  # https://github.com/prawnpdf/prawn/blob/master/lib/prawn/view.rb
  include Prawn::View

  BORDER_WIDTH = 0 # increase for debugging
  # HEADER_HEIGHT = 142
  HEADER_HEIGHT = 50

  TITLE_COLOUR = 'E26F55'
  TEXT_COLOUR = '737373'
  LINK_COLOUR = '1A9CAA'
  BOX_TEXT_COLOUR = '333333'
  BOX_COLOUR = 'E0E0E0'
  LOGO_BACKGROUND_COLOUR = '70CBD2'

  TEXT_LIGHT = '9F9F9F'
  FONT_SIZE = 8
  FONT_LARGE = 16

  DATE_FORMAT = '%d/%m/%Y'
  LABEL_WIDTH = 56.692913386
  LABEL_HEIGHT = 113.38582677

  # TO DO: Allow this to create any size the user wishes
  # 1 mm = 2.8346456693, so if a user wants 40 x 20 then that is going to be 113.38582677 x 56.692913386
  def document
    @document ||= Prawn::Document.new(page_size: [LABEL_HEIGHT, LABEL_WIDTH], page_layout: :portrait, margin: [0, 0, 0, 0])
  end

  def initialize
    font_setup
    begin
      layout_all
    rescue StandardError => e
      Rails.logger.debug e.message
    end
  end

  def font_setup
    font_families.update('Roboto' => {
                           normal: 'vendor/assets/fonts/Roboto-Regular.ttf',
                           italic: 'vendor/assets/fonts/Roboto-Italic.ttf',
                           bold: 'vendor/assets/fonts/Roboto-Bold.ttf',
                           medium: 'vendor/assets/fonts/Roboto-Medium.ttf',
                           light: 'vendor/assets/fonts/Roboto-Light.ttf'
                         })
    font 'Roboto'
  end

  def content; end

  def header
    standard_header('')
  end

  def layout_all
    repeat :all, dynamic: true do
      header
    end

    # bounding_box [bounds.left, bounds.top], width: bounds.width, height: bounds.height do
    bounding_box [bounds.left, bounds.top - HEADER_HEIGHT], width: bounds.width, height: bounds.height - HEADER_HEIGHT do
      content
    end
  end
end
