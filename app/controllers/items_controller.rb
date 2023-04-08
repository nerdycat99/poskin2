# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :order, only: %i[new create]

  def index
  end

  def new
    @item = @order.order_items.new
  end

  def create
    # in future allow a purchase to be made against a product or a variant for now MUST BE variant
    if variant.present? && variant.stock_for_order?(item_params['quantity'])
      sanitize_variant_id
      @item = order.order_items.new(item_params)
      if @item.save
        flash[:notice] = "Item successfully added to order"
        redirect_to new_order_item_path(@order.id)
      else
        flash[:notice] = "Unable to add item with sku code: #{unmatched_params['variant_id']} to order" unless @item.save
        render(:new, status: :unprocessable_entity)
      end
    else
      notice =  if !variant.present?
                  "Could not find an item for sku code: #{unmatched_params['variant_id']}"
                else
                  "Insufficient stock for sku code: #{unmatched_params['variant_id']} to fulfil order, #{variant.stock_count} items in stock."
                end
      flash[:notice] = notice
      @item = order.order_items.new
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def sanitize_variant_id
    params[:order_item]['variant_id'] = variant.id
  end

  def item_params
    params.require(:order_item).permit(:variant_id, :product_id, :quantity, :stock_adjustment_id)
  end

  def unmatched_params
    @unmatched_params ||= params.require(:order_item).extract!(:variant_id)
  end

  def variant
    @variant ||= Variant.find_by(sku_code: unmatched_params['variant_id'])
  end


  def order
    @order ||= Order.includes(:order_items).find_by(id: params['order_id'])
  end
end
