# frozen_string_literal: true

class Inventory::AdjustmentsController < ApplicationController
  def index
    @adjustments = variant.stock_adjustments
    @variant = variant
  end

  def new
    @stock_adjustment = variant.stock_adjustments.new
    @adjustment_types = StockAdjustment.adjustment_types.keys
  end

  def create
    @stock_adjustment = variant.stock_adjustments.new(stock_adjustment_params)
    return render(:new, status: :unprocessable_entity) unless @stock_adjustment.save

    redirect_to inventory_supplier_path(supplier.id)
  end

  private

  def stock_adjustment_params
    params.require(:stock_adjustment).permit(:quantity, :adjustment_type, :user_id)
  end

  def supplier
    @supplier ||= Supplier.find_by(id: params['supplier_id']) if params['supplier_id']
  end

  def product
    @product ||= supplier.products.find_by(id: params['product_id']) if params['product_id']
  end

  def variant
    @variant ||= product.variants.find_by(id: params['variant_id']) if params['variant_id']
  end
end
