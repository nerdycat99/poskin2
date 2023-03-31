# frozen_string_literal: true

class Product < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  belongs_to :supplier
  has_and_belongs_to_many :category_tags
  has_many :variants
  # accepts_nested_attributes_for :variants

  # Product.category_tags  #=> [<CategoryTag @name="Sports">, ...]
  # CategoryTag.products   #=> [<Product @name="UserA">, ...]
  # Product.category_tags.empty?

  scope :published, lambda {
    where(publish: true)
  }

  validates :accounting_code_id, :title, :description, :sku_code, :publish, :markup, presence: true

  validates :cost_price, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  def display_cost_price
    number_to_currency(format('%.2f', (cost_price.to_f / 100))) unless cost_price.nil?
  end

  def display_markup
    "#{markup}%" if markup.present?
  end

  def display_published
    publish ? 'Yes' : 'No'
  end

  def generated_sku
    unique_sku
  end

  def display_sku
    variants.none? ? sku_code : nil
  end

  # def display_title
  #   variants.none? ? "#{title} - #{sku_code}": "#{title}
  #   "#{title}"
  # end
end
