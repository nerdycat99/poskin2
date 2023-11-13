# frozen_string_literal: true

class ItemsController < ApplicationController
  include ItemsHelper

  before_action :order_item_quantity, only: %i[create]

  def index; end

  def new
    @item = @order.order_items.new
  end

  def create
    if variant_can_be_added_to_order?
      order = order_with_items
      order.order_items.new(item_params)
      flash[:notice] = "item successfully added to order"
      redirect_to item_to_be_added_to_orders_path(items: items_as_params(order.order_items))
    else
      message = if variant_for_order.blank?
                  "Could not find an item for sku code: #{sku_code}"
                elsif @quantity.to_i < 1
                  "Quantity cannot be blank or zero"
                elsif !variant_for_order.stock_for_order?(@quantity)
                  item_quantity_text = @quantity == 1 ? "#{@quantity} item" : "#{@quantity} items"
                  stock_quantity_text = variant_for_order.stock_count == 1 ? "is only #{variant_for_order.stock_count} item" : "are only #{variant_for_order.stock_count} items"
                  "Cannot add #{item_quantity_text}, there #{stock_quantity_text} in stock."
                else
                  "There was a problem, please check data provided and try again"
                end
      order = order_with_items
      flash[:alert] = message
      redirect_to item_to_be_added_to_orders_path(items: items_as_params(order.order_items), sku: sku_code, quantity: @quantity)
    end
  end

  def destroy; end

  private

  def items
    params['items']
  end

  def order_item_quantity
    @quantity = params[:order_item]['quantity']
  end

  def order_with_items
    items.present? ? add_items_to_order(Order.new(), items) : Order.new()
  end

  def sku_code
    @sku_code ||= params[:order_item]['variant_id']
  end

  def variant_for_order
    @variant_for_order ||= Variant.find_by(sku_code:)
  end

  def variant_can_be_added_to_order?
    @quantity.to_i > 0 && variant_for_order.present? && variant_for_order.stock_for_order?(@quantity)
  end

  def item_params
    params[:order_item]['variant_id'] = variant_for_order&.id #adjust as we are passed in the sku_code
    params.require(:order_item).permit(:variant_id, :product_id, :quantity, :stock_adjustment_id)
  end
end
