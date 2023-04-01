# frozen_string_literal: true

class Catalogue::ProductAttributesController < ApplicationController
  before_action :attribute_types, only: %i[new create]

  def new
    @product_attribute = ProductAttribute.new
  end

  def create
    @product_attribute = ProductAttribute.new(product_attribute_params)
    return render(:new, status: :unprocessable_entity) unless @product_attribute.save

    redirect_to new_catalogue_supplier_product_variant_path(supplier_id, product_id)
  end

  private

  def attribute_types
    @attribute_types = ProductAttribute.valid_attribute_types
  end

  def supplier_id
    params['supplier_id']
  end

  def product_id
    params['product_id']
  end

  def product_attribute_params
    params.require(:product_attribute).permit(:name, :value)
  end
end
