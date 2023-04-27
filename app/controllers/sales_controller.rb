# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :authenticate_user!

  def index; end

  def all
    # @orders = Order.includes(:order_items, :receipts).all.order(updated_at: :desc)
    @orders = Order.includes(:order_items, :receipts).where(payment_other_method: nil).order(updated_at: :desc)
  end

  def show
    @order = Order.includes(:order_items, :receipts).find_by(id: params['id'])
  end
end
