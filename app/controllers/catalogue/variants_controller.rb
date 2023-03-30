# frozen_string_literal: true

class Catalogue::VariantsController < ApplicationController
  before_action :variant_with_sku_code, only: [:new]

  def new
    @variant.product_attributes_variants.build
    @variant.product_attributes_variants.build
  end

  def create
    @variant = product.variants.new(variant_params)
    if @variant.save
      redirect_to catalogue_supplier_path(supplier.id)
    else
      return render(:new, status: :unprocessable_entity)
    end
  end

  private

  def variant
    @variant ||= product.variants.new
  end

  def variant_with_sku_code
    variant.sku_code = sku_code
    variant
  end

  def sku_code
    @sku_code ||= @variant.generated_sku
  end

  def supplier
    @supplier ||= Supplier.find_by(id: supplier_id)
  end

  def product
    @product ||= supplier.products.find_by(id: product_id)
  end

  def supplier_id
    @supplier_id = params['supplier_id']
  end

  def product_id
    @product_id = params['product_id']
  end

  def variant_params
    params.require(:variant).permit(:quantity, :sku_code, product_attributes_variants_attributes: [:product_attribute_id])
  end
end