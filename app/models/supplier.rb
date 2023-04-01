# frozen_string_literal: true

class Supplier < ApplicationRecord
  has_many :products, dependent: :destroy
  belongs_to :address

  accepts_nested_attributes_for :address

  # validates_presence_of   :username, :message => 'Please Enter User  Name.'
  validates :name, :phone, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def display_address
    address.display_address
  end
end
