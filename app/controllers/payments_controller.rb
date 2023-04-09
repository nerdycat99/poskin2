class PaymentsController < ApplicationController
  before_action :existing_order, only: %i[new create]
  before_action :sanitize_params, only: %i[create]

  def new
    @payment_methods = Order.payment_methods.keys
    # @payment_methods = ['Visa', 'Mastercard', 'Debit', 'Cash', 'Bank Transfer']
  end

  def create
    # put this in a transation???
    if @existing_order.update(order_payment_params)
      adjust_stock_count
      redirect_to order_path(@existing_order.id)
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def adjust_stock_count
    responses = @existing_order.order_items.map{|item| item.adjust_stock(current_user.id) }
    # responses will be an array of true/false like this [true] we can use in transaction above?
  end

  def sanitize_params
    params[:order]['payment_amount'] = payment_amount
  end

  def unmatched_params
    @unmatched_params ||= params.require(:order).extract!(:payment_amount)
  end

  def payment_amount
    (unmatched_params['payment_amount'].gsub(/[^0-9.]/, '').to_f * 100).to_i
  end

  def order_id
    params['order_id']
  end

  def existing_order
    @existing_order ||= Order.includes(:order_items).find_by(id: params['order_id'])
  end

  def order_payment_params
    params.require(:order).permit(:state, :payment_method, :payment_amount, :notes)
    # params.require(:order).permit(:customer_id, :state, :payment_method, :payment_other_method, :payment_amount, :adjustments, :delivery, :notes, :first_name, :last_name, :email_address, :phone_number)
  end
end
