# frozen_string_literal: true

class Catalogue::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :sanitize_params, only: %i[create update]
  before_action :product_with_sku_code, only: [:new]
  before_action :calculation_methods, only: %i[new create edit update]
  before_action :existing_product, only: %i[edit update destroy show]

  def show; end

  def new
    session.delete(:product_params)
  end

  def edit; end

  def create
    session[:product_params] = params[:product] #gets the params passed into create and pushes them back into new

    if (valid_cost_price? || valid_retail_price?) && product_params[:markup].present?
      new_product = supplier.products.new(product_params) if session[:product_params].present?
      if new_product.save
        session.delete(:product_params)
        return redirect_to catalogue_supplier_path(supplier.id)
      end
    end
    redirect_to new_catalogue_supplier_product_path(supplier.id)
  end

  def update
    return render(:edit, status: :unprocessable_entity) unless @existing_product.update(product_params)

    redirect_to catalogue_supplier_path(supplier.id)
  end

  # rubocop:disable Layout/LineLength
  def destroy
    alert_message = 'Product and all of its Variants have been deleted'
    if @existing_product.stock? || @existing_product.been_sold?
      alert_message = 'Unable to delete Product, a variant of this Product has existing stock or has been sold one or more times. Product has been unpublished instead.'
      @existing_product.update(publish: false)
    else
      @existing_product.remove!
    end

    flash[:notice] = alert_message
    redirect_to catalogue_supplier_path(supplier.id)
  end
  # rubocop:enable Layout/LineLength

  private

  def valid_retail_price?
    product_params[:retail_price].present? && product_params[:retail_price] > 0
  end

  def valid_cost_price?
    product_params[:cost_price].present? && product_params[:cost_price] > 0
  end

  def calculation_methods
    @calculation_methods = [OpenStruct.new(name: 'Cost Price Method', value: 0), OpenStruct.new(name: 'Retail Price Method', value: 1)]
  end

  def existing_product
    @existing_product = supplier.products.find_by(id: params['id'])
  end

  def product
    @product ||= supplier.products.new
  end

  def product_with_sku_code
    return product.assign_attributes(session[:product_params]) if session[:product_params].present?

    product.sku_code = sku_code
    product
  end

  def sku_code
    @sku_code ||= @product.generated_sku
  end

  def sanitize_params
    params.require(:product).permit(:supplier_id, :accounting_code_id, :title, :description, :notes, :sku_code, :publish, :markup, :cost_price)

    params[:product]['markup'] = markup
    params[:product]['publish'] = publish
    params[:product]['cost_price'] = cost_price
    params[:product]['retail_price'] = retail_price
    params[:product]['price_calc_method'] = price_calc_method
  end

  def unmatched_params
    @unmatched_params ||= params.require(:product).extract!(:publish, :markup, :cost_price, :retail_price, :price_calc_method)
  end

  def cost_price
    (unmatched_params['cost_price'].gsub(/[^0-9.]/, '').to_f * 100).to_i if unmatched_params['cost_price']
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
    unmatched_params['markup'].present? ? unmatched_params['markup'].gsub(/[^0-9]/, '') : nil
  end

  def publish
    unmatched_params['publish'] == 'Yes'
  end

  def product_params
    params.require(:product).permit(:supplier_id, :accounting_code_id, :title, :description, :notes, :sku_code, :publish, :markup, :cost_price,
                                    :price_calc_method, :retail_price)
  end

  def supplier
    @supplier ||= Supplier.find_by(id: supplier_id)
  end

  def supplier_id
    @supplier_id = params['supplier_id']
  end
end
