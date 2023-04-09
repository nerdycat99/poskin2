# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :existing_order, only: %i[edit update show]

  def new
  end

  def create
    @order = Order.new(state: 'raised')
    if @order.save
      redirect_to new_order_item_path(@order.id)
    else
      flash[:notice] = 'There was a problem registering a new order, please try again'
      redirect_to sales_path
    end
  end

  def edit
  end

  def update
    if email_address.present?
      if existing_customer.present?
        @existing_order.update(customer_id: existing_customer.id)
      else
        create_new_customer_and_update_order
      end
    end
    redirect_to new_order_payment_path(@existing_order)
  end

  def show
    order = Order.find_by(id: params['id'])
    @receipt = order.receipts.new #see if we can prevent this from happening if a receipt already exists?
  end

  private

  def email_address
    order_params['email_address']
  end

  def existing_customer
    Customer.find_by(email_address: email_address)
  end

  def create_new_customer_and_update_order
    customer = Customer.new(first_name: order_params['first_name'], last_name: order_params['last_name'], email_address: order_params['email_address'], phone_number: order_params['phone_number'])
    @existing_order.update(customer_id: customer.id) if customer.save
  end

  def existing_order
    @existing_order ||= Order.includes(:order_items).find_by(id: params['id'])
  end


  def order_params
    params.require(:order).permit(:customer_id, :state, :payment_method, :payment_other_method, :payment_amount, :adjustments, :delivery, :notes, :first_name, :last_name, :email_address, :phone_number)
    # params.require(:order).permit(:customer_id, :state, :payment_method, :payment_other_method, :payment_amount, :adjustments, :delivery, :notes, :first_name, :last_name, :email_address, :phone_number, customer_attributes: [:first_name, :last_name, :email_address, :phone_number])
  end
end

# initially just record the email address in the order!!!
# in create show the list of customers by email address
# user can select (in time will be search) - ot click on create new