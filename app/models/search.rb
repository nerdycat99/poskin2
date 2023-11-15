# frozen_string_literal: true

class Search

  attr_accessor :description, :string
  attr_accessor :sku_code, :string

  def initialize(sku_code:, description:)
    self.sku_code = sku_code
    self.description = description
  end

  def self.variants_for(search_results)
    Variant.includes(:product, :stock_adjustments, product_attributes_variants: [:product_attribute]).where(id: search_results)
  end

  def results
    results = if sku_code.present?
                Variant.includes(:product).where(sku_code:)
              elsif description.present?
                products = Product.includes(:variants).where("title ~* ?", self.description)
                products.map{|product| product.variants}.flatten
              end
    results&.map{|var| var.id}
  end
end
