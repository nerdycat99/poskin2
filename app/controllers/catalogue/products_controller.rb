# frozen_string_literal: true

class Catalogue::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :sanitize_params, only: [:create]
  before_action :product_with_sku_code, only: [:new]

  def new; end

  def create
    @product = supplier.products.new(product_params)
    return render(:new, status: :unprocessable_entity) unless @product.save

    redirect_to catalogue_supplier_path(supplier.id)
  end

  private

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
