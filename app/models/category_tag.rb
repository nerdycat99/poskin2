# frozen_string_literal: true

class CategoryTag < ApplicationRecord
  has_and_belongs_to_many :products
end
