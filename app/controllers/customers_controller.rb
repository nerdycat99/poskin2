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

  def create
    @customer = Customer.new(customer_params)
    return render(:new, status: :unprocessable_entity) unless @customer.save

    flash[:notice] = 'New customer successfully created'
    redirect_to customers_path
  end

  def update
    return render(:edit, status: :unprocessable_entity) unless @customer.update(customer_params)

    flash[:notice] = 'Customer details successfully updated'
    redirect_to customers_path
  end

  private

  def customer
    @customer ||= if params[:id].present?
                    Customer.find_by(id: params[:id])
                  else
                    Customer.new
                  end
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email_address, :phone_number)
  end
end
