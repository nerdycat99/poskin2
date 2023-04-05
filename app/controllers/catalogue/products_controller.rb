# frozen_string_literal: true

class Catalogue::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :sanitize_params, only: %i[create update]
  before_action :product_with_sku_code, only: [:new]
  before_action :existing_product, only: %i[edit update destroy]

  def new; end

  def edit; end

  def create
    @product = supplier.products.new(product_params)
    return render(:new, status: :unprocessable_entity) unless @product.save

    redirect_to catalogue_supplier_path(supplier.id)
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

  def existing_product
    @existing_product = supplier.products.find_by(id: params['id'])
  end

  def product
    @product ||= supplier.products.new
  end

  def product_with_sku_code
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
  end

  def unmatched_params
    @unmatched_params ||= params.require(:product).extract!(:publish, :markup, :cost_price)
  end

  def cost_price
    (unmatched_params['cost_price'].gsub(/[^0-9,.]/, '').to_f * 100).to_i
  end

  def markup
    unmatched_params['markup'].gsub(/[^0-9]/, '')
  end

  def publish
    unmatched_params['publish'] == 'Yes'
  end

  def product_params
    params.require(:product).permit(:supplier_id, :accounting_code_id, :title, :description, :notes, :sku_code, :publish, :markup, :cost_price)
  end

  def supplier
    @supplier ||= Supplier.find_by(id: supplier_id)
  end

  def supplier_id
    @supplier_id = params['supplier_id']
  end
end
