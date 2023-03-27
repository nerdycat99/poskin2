module ApplicationHelper
  def unique_sku
    candidate_sku = (SecureRandom.random_number(9e5) + 1e5).to_i
    unique_sku if [product_sku_codes, variant_sku_codes].flatten.reject(&:blank?).include?(candidate_sku)
    candidate_sku
  end

  def product_sku_codes
    Product.all.map(&:sku_code)
  end

  def variant_sku_codes
    Variant.all.map(&:sku_code)
  end

end
