# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :remember_page, only: [:index]

  def index; end

  def all
    @orders = Order.includes(:customer, order_items: [variant:[:product]]).where(payment_other_method: nil).order(created_at: :desc)
  end

  def show
    @order = Order.includes(:order_items, :receipts).find_by(id: params['id'])
  end
end
