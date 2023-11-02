# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :order, only: %i[new create destroy]
  before_action :item, only: %i[destroy]

  def index; end

  def new
    @item = @order.order_items.new
  end

  def create
    variant = Variant.find_by(sku_code:)
    if variant.present?
      params[:order_item]['variant_id'] = variant.id # this is because we pass in the sku not id of variant
      @item = order.order_items.new(item_params)
      if @item.save
        flash[:notice] = 'Item successfully added to order'
        redirect_to new_order_item_path(@order.id)
      else
        flash[:notice] = "Unable to add item with sku code: #{sku_code} to order" unless @item.save
        render(:new, status: :unprocessable_entity)
      end
    else
      flash[:notice] = "Could not find an item for sku code: #{sku_code}"
      @item = order.order_items.new
      render(:new, status: :unprocessable_entity)
    end
  end

  def destroy
    if @item&.delete
      redirect_to new_order_item_path(@order)
    else
      flash[:notice] = 'There was a problem removing the item' unless @item&.delete
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def item
    @item ||= @order.order_items.find_by(id: params['id'])
  end

  def variant_params
    @variant_params ||= params.require(:order_item).extract!(:variant_id)
  end

  def sku_code
    @sku_code ||= variant_params['variant_id']
  end

  def item_params
    params.require(:order_item).permit(:variant_id, :product_id, :quantity, :stock_adjustment_id)
  end

  def order
    # TO DO: fetch the variants and the products as well
    @order ||= Order.includes(:order_items).find_by(id: params['order_id'])
  end
end
