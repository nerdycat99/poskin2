# frozen_string_literal: true

class ReferralPdf < BaseReceiptPdf
  include ApplicationHelper

  LARGE_TEXT_COLOUR = '000000'
  TEXT_LIGHT = '9F9F9F'
  LINE_COLOUR = 'D7D5D5'
  FONT_SIZE = 8
  LARGE_FONT_SIZE = 12
  CELL_PADDING = [2, 4.5, 4.5, 5].freeze
  CELL_PADDING_PATIENT = [0, 5, 5, 0].freeze

  def initialize(content, date)
    @content = content
    @date = date_formatter(date, '%a %d/%m/%Y %H:%M:%S')
    # @date = date_formatter(date, '%A %e %B %Y')
    super()
  end

  def header
    standard_header
  end

  def content
    move_down 10
    company_info
    move_down 3
    transaction_timestamp
    # notification_text
    # move_down 10
    # referral_box
    # move_down 18
    # about_text
    # move_down 24
    # about_meth
  end

  def company_info
    indent(22, 0) do
      text 'ABN 123 456 789', size: 7, style: :light, color: BOX_TEXT_COLOUR
    end
    move_down 3
    indent(16, 0) do
      text 'www.australian-glass.com.au', size: 5, style: :light, color: BOX_TEXT_COLOUR
    end
  end

  def transaction_timestamp
    indent(10, 0) do
      text @date, size: 7, style: :light, color: BOX_TEXT_COLOUR
    end
  end

  def notification_text
    # indent(39, 39) do
    indent(0, o) do
      text 'S-Check App Notification for GP', size: 18, style: :bold, color: TITLE_COLOUR
      move_down 12
      text 'This letter has been automatically generated and downloaded from the S-Check app.', size: 12, style: :normal, color: TEXT_COLOUR
    end
  end

  def referral_box
    number_of_lines = 0
    @content.map { |c| number_of_lines += (c.length / 91) + 1 }

    indent(39, 39) do
      height_for_lines = 16 + 17 + 16 + (number_of_lines * 17) + 16
      bounding_box([0, 570], width: 520, height: height_for_lines) do
        indent(10, 10) do # left and right padding
          pad_top(5) { text @referral_date, size: 12, style: :normal, color: BOX_TEXT_COLOUR }
          move_down 16
          @content.each do |content_block|
            text content_block, size: 12, leading: 5, style: :normal, color: BOX_TEXT_COLOUR
          end
        end
      end

      stroke do
        stroke_color BOX_COLOUR
        rounded_rectangle [0, 570 + 16], 520 + 0, height_for_lines + 0, 6
      end
    end
  end

  def about_text
    indent(39, 39) do
      text 'About S-Check', size: 18, style: :bold, color: TITLE_COLOUR
      move_down 12
      formatted_text [
        {
          text: 'S-Check is an app designed to support people to monitor their methamphetamine use and understand the impact it has on their health and wellbeing. You can find out more about the app and the research behind it at ', color: TEXT_COLOUR
        },
        { text: 'https://scheckapp.org.au', link: 'https://scheckapp.org.au', color: LINK_COLOUR }
      ], leading: 5, size: 12, style: :normal
      move_down 12
      text "It is based on the S-Check model of care, a low-threshold intervention developed and used at St Vincent's Hospital, Sydney.", size: 12,
                                                                                                                                          leading: 5, style: :normal, color: TEXT_COLOUR
    end
  end

  def about_meth
    indent(39, 39) do
      text 'About Methamphetamine', size: 18, style: :bold, color: TITLE_COLOUR
      move_down 12
      text 'Methamphetamine is a psycho-stimulant drug available in powder, paste or crystalline form and is typically snorted, smoked or injected.',
           size: 12, leading: 5, style: :normal, color: TEXT_COLOUR
      move_down 12
      text 'In 2019, of Australians aged 14 or over who reported using methamphetamine in the previous 12 months, 50% reported using the ‘crystalline’ form (“Ice”) of the drug, of whom 30% were using at least once a week or more.',
           size: 12, leading: 5, style: :normal, color: TEXT_COLOUR
      move_down 12
      text 'Methamphetamine is a powerful central nervous systems (CNS) stimulant that can induce feelings of euphoria, alertness, increased confidence and wakefulness. Acute effects can last for 8-24 hours.',
           size: 12, leading: 5, style: :normal, color: TEXT_COLOUR
      move_down 12
      text 'Repeated use of methamphetamine may cause significant depletion of CNS neurotransmitters, accompanied by depression, excessive tiredness and fatigue.',
           size: 12, leading: 5, style: :normal, color: TEXT_COLOUR
      move_down 12
      text 'Adverse effects include but are not limited to: anxiety, low mood, weight loss, poor appetite, hallucinations, agitation, sleep problems, teeth grinding and paranoia.',
           size: 12, leading: 5, style: :normal, color: TEXT_COLOUR
      move_down 12
      formatted_text [
        { text: 'Learn more about methamphetamine in our ', color: TEXT_COLOUR },
        { text: 'clinical guide for primary care health professionals.', link: 'https://scheckapp.org.au', color: LINK_COLOUR }
      ], leading: 5, size: 12, style: :normal
    end
  end

  private

  def header_logo(width:, image:)
    logo = Rails.root.join("app/assets/images/#{image}.png")
    image logo, width:
  rescue StandardError => e
    Rails.logger.error "header image error: #{e.message}"
  end

  def standard_header(_height = 100)
    # stroke do
    #   fill_color LOGO_BACKGROUND_COLOUR
    #   stroke_color LOGO_BACKGROUND_COLOUR
    #   fill_and_stroke_rounded_rectangle [bounds.left, bounds.top], bounds.width, 20, 0
    # end

    logo_width = 70

    move_down 0
    # move_down 30
    indent(14, 0) do
      # indent(30, 0) do
      header_logo(width: logo_width, image: 'ag_logo')
      move_cursor_to bounds.height
    end
  end
end
