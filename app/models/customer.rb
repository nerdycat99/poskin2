# frozen_string_literal: true

class Customer < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  has_many :orders

  # removed this validation so a customer can be created with just a name
  # validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :email_address_or_name

  def display_date
    convert_to_users_timezone(created_at).to_fs(:long)
  end

  def email_address_or_name
    unless (first_name.present? && last_name.present?) || email_address.present?
      self.errors.add :base, 'Please either enter an email address of a first and last name'
    end
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
