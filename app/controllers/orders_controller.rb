# frozen_string_literal: true

class OrdersController < ApplicationController
  def new
    @order = Order.new
    # @order.customer.build
  end

  def create
    @order = Order.new(order_params)
    return render(:new, status: :unprocessable_entity) unless @order.save

    # next stage
    redirect_to order_items_path(@order.id)
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :state, :payment_method, :payment_other_method, :payment_amount, :adjustments, :delivery, :notes, :first_name, :last_name, :email_address, :phone_number)
    # params.require(:order).permit(:customer_id, :state, :payment_method, :payment_other_method, :payment_amount, :adjustments, :delivery, :notes, :first_name, :last_name, :email_address, :phone_number, customer_attributes: [:first_name, :last_name, :email_address, :phone_number])
  end
end

# initially just record the email address in the order!!!
# in create show the list of customers by email address
# user can select (in time will be search) - ot click on create new