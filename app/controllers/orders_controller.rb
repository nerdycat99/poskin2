# frozen_string_literal: true

class OrdersController < ApplicationController
  include ItemsHelper

  before_action :sanitize_params, only: %i[create]

  def show
    order = Order.find_by(id: params['id'])
    @receipt = order.receipts.new #not sure why we have this here??
  end

  def new
    @order = Order.new(state: 'raised')
    add_items_to_order(@order, items) if items.present?
    @item = @order.items.new
    @items = items
    @quantity = quantity
    @sku_code = sku_code
  end

  def new_customer
    @items = items
    @customer = Customer.new
  end

  def edit; end

  def update; end

  def create
    @order = Order.new(order_params)
    add_items_to_order(@order, items) if items.present?

    # TO DO: put this in a transaction AND validate fields on order
    if @order.update(customer_id: customer_id, state: 'paid')
      adjust_stock_count
      flash[:notice] = 'Order was successfully created'
      redirect_to order_path(@order.id)
    else
      flash[:alert] = 'Please select a payment method'
      if customer_id.present?
        redirect_to new_order_payments_path(items: items_as_params(@order.order_items), customer: customer_id)
      else
        redirect_to new_order_without_customer_payments_path(items: items_as_params(@order.order_items))
      end
    end
  end

  def destroy
    redirect_to sales_path if @existing_order.destroy
  end

  def remove_item
    redirect_to item_to_be_added_to_orders_path(items: remove_item_from_items(item, items))
  end

  private

  def quantity
    params['quantity']
  end

  def sku_code
    params['sku']
  end

  def item
    @item ||= params['item']
  end

  def items
    @items ||= params['items']
  end

  def customer_id
    @customer_id ||= params['customer']
  end

  def order_params
    params.require(:order).permit(:customer_id, :state, :payment_method, :payment_other_method, :payment_amount, :adjustments, :delivery, :notes,
                                  :first_name, :last_name, :email_address, :phone_number, :adjustment_amount, :delivery_amount)
    # params.require(:order).permit(:customer_id, :state, :payment_method, :payment_other_method, :payment_amount, :adjustments, :delivery, :notes, :first_name, :last_name, :email_address, :phone_number, customer_attributes: [:first_name, :last_name, :email_address, :phone_number])
  end

  def sanitize_params
    params[:order]['payment_amount'] = payment_amount
    params[:order]['adjustment_amount'] = adjustment_amount
    params[:order]['delivery_amount'] = delivery_amount
  end

  def unmatched_params
    @unmatched_params ||= params.require(:order).extract!(:payment_amount, :adjustment_amount, :delivery_amount)
  end

  def adjustment_amount
    (unmatched_params['adjustment_amount'].gsub(/[^0-9.]/, '').to_f * 100).to_i
  end

  def delivery_amount
    (unmatched_params['delivery_amount'].gsub(/[^0-9.]/, '').to_f * 100).to_i
  end

  def payment_amount
    (unmatched_params['payment_amount'].gsub(/[^0-9.]/, '').to_f * 100).to_i
  end

  def adjust_stock_count
    responses = @order.order_items.map { |item| item.adjust_stock(current_user.id, @order.id) }
    # responses will be an array of true/false like this [true] we can use in transaction above?
  end
end
