# frozen_string_literal: true

class Supplier < ApplicationRecord
  has_many :products, dependent: :destroy
  belongs_to :address

  accepts_nested_attributes_for :address

  # validates_presence_of   :username, :message => 'Please Enter User  Name.'
  validates :name, :phone, presence: true
  validates :sales_tax_registered, inclusion: { in: [true, false] }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  delegate :display_address, to: :address
end
