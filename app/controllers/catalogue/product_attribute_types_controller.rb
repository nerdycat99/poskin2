# frozen_string_literal: true

class Catalogue::ProductAttributeTypesController < ApplicationController
  def new
    @product_attribute_type = ProductAttributeType.new
  end

  def create
    @product_attribute_type = ProductAttributeType.new(product_attribute_type_params)
    return render(:new, status: :unprocessable_entity) unless @product_attribute_type.save

    redirect_to new_catalogue_supplier_product_variant_path(supplier_id, product_id)
  end

  private

  def supplier_id
    params['supplier_id']
  end

  def product_id
    params['product_id']
  end

  def product_attribute_type_params
    params.require(:product_attribute_type).permit(:name)
  end
end

