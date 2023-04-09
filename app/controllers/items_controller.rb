# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :order, only: %i[new create]

  def index
  end

  def new
    # @order = order
    @item = @order.order_items.new
  end

  def create
    variant = Variant.find_by(sku_code: sku_code)
    if variant.present?
      params['variant_id'] = variant.id
      @item = order.order_items.new(item_params)
      if @item.save
        flash[:notice] = "Item successfully added to order"
        redirect_to new_order_item_path(@order.id)
      else
        flash[:notice] = "Unable to add item with sku code: #{sku_code} to order" unless @item.save
        render(:new, status: :unprocessable_entity)
      end
    else
      flash[:notice] = "Could not find an item for sku code: #{sku_code}"
      # redirect_to new_order_item_path(@order.id)
      @item = order.order_items.new
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def item_params
    params.require(:order_item).permit(:variant_id, :product_id, :quantity, :stock_adjustment_id)
  end

  def sku_code
    item_params['variant_id']
  end


  def order
    # TO DO: fetch the variants and the products as well
    @order ||= Order.includes(:order_items).find_by(id: params['order_id'])
  end
end



      # t.integer :variant_id
      # t.integer :product_id
      # t.integer :quantity
      # t.integer :stock_adjustment_id