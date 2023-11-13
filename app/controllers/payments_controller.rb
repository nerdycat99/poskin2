# frozen_string_literal: true

class PaymentsController < ApplicationController
  include ItemsHelper

  before_action :payment_methods, only: %i[new_order_payment]

  def new_order_payment
    @order = Order.new(state: 'raised')
    add_items_to_order(@order, items) if items.present?
    @items = items
    @customer = customer
  end

  private

  def customer
    params['customer']
  end

  def items
    params['items']
  end

  def payment_methods
    @payment_methods ||= Order.display_payment_methods
  end

  def order_id
    params['order_id']
  end

  def existing_order
    @existing_order ||= Order.includes(:order_items).find_by(id: params['order_id'])
  end

  def order_payment_params
    params.require(:order).permit(:state, :payment_method, :payment_amount, :notes, :adjustment_amount, :delivery_amount)
    # params.require(:order).permit(:customer_id, :state, :payment_method, :payment_other_method, :payment_amount, :adjustments, :delivery, :notes, :first_name, :last_name, :email_address, :phone_number)
  end
end
