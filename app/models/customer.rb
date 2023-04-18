# frozen_string_literal: true

class Customer < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  has_many :orders

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def display_date
    convert_to_users_timezone(created_at).to_fs(:long)
  end

  def display_name
    if first_name && last_name
      "#{first_name} #{last_name}"
    elsif first_name
      "#{first_name}"
    else
      "#{email_address}"
    end
  end
end
