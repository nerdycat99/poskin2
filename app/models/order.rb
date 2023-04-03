# frozen_string_literal: true

class Order < ApplicationRecord

  # how to have this but make it optional
  # belongs_to :customer
  # accepts_nested_attributes_for :customer

  enum state: { raised: 0, paid: 1, failed: 2, refunded: 3, cancelled: 4 }
  # enum payment_method: { credit_card: 0, debit_card: 1, other: 2 } # this needs to allow nil
end
