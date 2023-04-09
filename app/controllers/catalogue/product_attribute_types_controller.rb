# frozen_string_literal: true

class Catalogue::ProductAttributeTypesController < ApplicationController
  before_action :supplier_id, :product_id, only: %i[index new create destroy]
  before_action :product_attribute_type, only: %i[destroy]

  def index
    @product_attribute_types = ProductAttributeType.all
  end

  def new
    @product_attribute_type = ProductAttributeType.new
  end

  def create
    @product_attribute_type = ProductAttributeType.new(product_attribute_type_params)
    return render(:new, status: :unprocessable_entity) unless @product_attribute_type.save

    redirect_to new_catalogue_supplier_product_variant_path(supplier_id, product_id)
  end

  def destroy
    flash.now.alert = if product_attribute_type&.remove!
                        'Attribute Type was removed'
                      else
                        'Unable to remove the Attribute Type'
                      end
    redirect_to catalogue_supplier_product_product_attribute_types_path(@supplier_id, @product_id)
  end

  private

  def product_attribute_type
    @product_attribute_type = ProductAttributeType.find_by(id: params['id'])
  end

  def supplier_id
    @supplier_id ||= params['supplier_id']
  end

  def product_id
    @product_id ||= params['product_id']
  end

  def product_attribute_type_params
    params.require(:product_attribute_type).permit(:name)
  end
end
