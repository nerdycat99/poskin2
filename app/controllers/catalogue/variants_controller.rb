# frozen_string_literal: true

class Catalogue::VariantsController < ApplicationController
  before_action :authenticate_user!
  before_action :variant_with_sku_code, only: [:new]
  before_action :sanitize_params, only: %i[create update]
  before_action :attribute_types, only: %i[new edit create update]
  before_action :number_of_rows_for_attribute_types, only: %i[new edit create update]
  before_action :existing_variant, only: %i[edit update destroy show]
  before_action :calculation_methods, only: %i[new create edit update]

  def new
    0.upto(@attribute_types.count - 1) do |_loop_index|
      @variant.product_attributes_variants.build
    end
  end

  def edit
    0.upto(@existing_variant.attribute_types_not_set.count - 1) do
      @existing_variant.product_attributes_variants.build
    end
  end

  def show
  end

  def create
    @variant = product.variants.new(variant_params)
    return render(:new, status: :unprocessable_entity) unless @variant.save

    redirect_to catalogue_supplier_path(supplier.id)
  end

  def update
    product_attribute_params = params.require(:variant).extract!(:product_attributes_variants_attributes)

    if @existing_variant.update(variant_params)
      @existing_variant.update_product_attributes(product_attribute_params)
      redirect_to catalogue_supplier_path(supplier.id)
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    alert_message = 'Variant has been deleted'
    if @existing_variant.stock? || @existing_variant.been_sold?
      alert_message = 'Unable to delete Variant, either it has existing stock or has been sold one or more times.'
    else
      @existing_variant.remove!
    end

    flash[:notice] = alert_message
    redirect_to catalogue_supplier_path(supplier.id)
  end

  private

  def calculation_methods
    @calculation_methods = [OpenStruct.new(name: 'Cost Price Method', value: 0), OpenStruct.new(name: 'Retail Price Method', value: 1)]
  end

  def attribute_types
    @attribute_types = ProductAttribute.valid_attribute_types
  end

  def number_of_rows_for_attribute_types
    @number_of_rows_for_attribute_types ||= Variant.number_of_attribute_tows
  end

  def existing_variant
    @existing_variant = product.variants.find_by(id: params['id'])
  end

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

  def sanitize_params
    # params.require(:variant).permit(:quantity, :sku_code, :cost_price, :markup, product_attributes_variants_attributes: [:product_attribute_id])

    params[:variant]['markup'] = markup
    params[:variant]['cost_price'] = cost_price
    params[:variant]['retail_price'] = retail_price
    params[:variant]['price_calc_method'] = price_calc_method
  end

  def unmatched_params
    @unmatched_params ||= params.require(:variant).extract!(:markup, :cost_price, :retail_price, :price_calc_method)
  end

  def cost_price
    (unmatched_params['cost_price'].gsub(/[^0-9.]/, '').to_f * 100).to_i if unmatched_params['cost_price'].present?
  end

  def retail_price
    (unmatched_params['retail_price'].gsub(/[^0-9.]/, '').to_f * 100).to_i if unmatched_params['retail_price']
  end

  def price_calc_method
    if unmatched_params['price_calc_method'].blank?
      nil
    else
      unmatched_params['price_calc_method'].to_i
    end
  end

  def markup
    return if unmatched_params['markup'].blank?

    unmatched_params['markup']&.gsub(/[^0-9]/, '')
  end

  def variant_params
    params.require(:variant).permit(:quantity, :sku_code, :cost_price, :price_calc_method, :retail_price, :markup, product_attributes_variants_attributes: [:product_attribute_id])
  end
end
