# frozen_string_literal: true

module ApplicationHelper
  def unique_sku
    candidate_sku = (SecureRandom.random_number(9e5) + 1e5).to_i
    unique_sku if [product_sku_codes, variant_sku_codes].flatten.compact_blank.include?(candidate_sku)
    candidate_sku
  end

  def product_sku_codes
    Product.all.map(&:sku_code)
  end

  def variant_sku_codes
    Variant.all.map(&:sku_code)
  end

  # def convert_date(date)
  #   date.to_date
  # rescue Date::Error => e
  #   e
  # end

  # def convert_to_datetime(date)
  #   date.to_datetime
  # rescue Date::Error => e
  #   e
  # end

  def date_formatter(date, format = '%Y-%m-%d')
    date.strftime(format)
  end
end
