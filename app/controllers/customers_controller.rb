# frozen_string_literal: true

class CustomersController < ApplicationController
  before_action :authenticate_user!

  before_action :customer, only: %i[new edit update show]

  def index
    @customers = Customer.all.order(updated_at: :desc)
  end

  def new
  end

  def edit
  end

  def show
    @orders ||= @customer.orders.order(created_at: :desc)
  end

  def existing_items
    @existing_items = JSON.parse(items) if items.present?
  end

  def create
    @customer = if existing_customer.present?
                  existing_customer
                else
                  Customer.create(customer_params)
                end

    if items.present?
      return redirect_to new_order_payments_path(items: items, customer: @customer.id) if @customer.persisted?

      redirect_to new_customer_for_orders_path(items: items)
      flash[:alert] = 'There was a problem creating the customer, plese provide either a first and last name or an email address'
    else
      return render(:new, status: :unprocessable_entity) unless @customer.persisted?

      flash[:notice] = 'New customer successfully created'
      redirect_to customers_path
    end
  end

  def update
    return render(:edit, status: :unprocessable_entity) unless @customer.update(customer_params)

    flash[:notice] = 'Customer details successfully updated'
    redirect_to customers_path
  end

  private

  def items
    params['items']
  end

  def existing_customer
    Customer.find_by(email_address: customer_params['email_address']) unless customer_params['email_address'].blank?
  end

  # we can probably removed the new part as we are doing that elswhere, only used on edit/update and show now
  def customer
    @customer ||= if params[:id].present?
                    Customer.find_by(id: params[:id])
                  else
                    Customer.new
                  end
  end

  def customer_params
    # we may need to remove the items first
    params.require(:customer).permit(:first_name, :last_name, :email_address, :phone_number)
  end
end
