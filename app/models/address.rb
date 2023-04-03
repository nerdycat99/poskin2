# frozen_string_literal: true

class Address < ApplicationRecord
  has_one :supplier
  belongs_to :country

  def display_address
    [first_line, second_line, city, state, postcode, display_country].compact_blank.join(', ')
  end

  def display_country
    country.country.titleize
  end
end
