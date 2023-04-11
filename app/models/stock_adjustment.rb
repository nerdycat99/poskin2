# frozen_string_literal: true

class StockAdjustment < ApplicationRecord
  belongs_to :variant
  belongs_to :user

  enum adjustment_type: { received: 0, refunded: 1, purchased: 2, returned: 3 }

  validates :quantity, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  def quantity_by_type
    case adjustment_type
    when 'purchased', 'returned'
      quantity * -1
    else
      quantity
    end
  end

  def user_reference
    user.email
  end
end
