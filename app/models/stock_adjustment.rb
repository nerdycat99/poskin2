# frozen_string_literal: true

class StockAdjustment < ApplicationRecord
  include ApplicationHelper

  belongs_to :variant
  belongs_to :user

  enum adjustment_type: { received: 0, refunded: 1, purchased: 2, returned: 3, removed: 4 }

  validates :quantity, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  def display_date
    convert_to_users_timezone(created_at).to_fs(:long)
  end

  def quantity_by_type
    case adjustment_type
    when 'purchased', 'returned', 'removed'
      quantity * -1
    else
      quantity
    end
  end

  def user_reference
    user.email
  end
end
