# frozen_string_literal: true

class ProductAttribute < ApplicationRecord
  # has_and_belongs_to_many :variants # this feels wrong, these shoudl be associated to the prod_attr_variants

  scope :magnitude, lambda {
    where(name: 'size')
  }

  scope :colour, lambda {
    where(name: 'colour')
  }
end
