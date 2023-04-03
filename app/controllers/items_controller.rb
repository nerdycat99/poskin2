# frozen_string_literal: true

class ItemsController < ApplicationController

  def index
    @order = order
  end

  private

  def order
    @order ||= Order.find_by(id: params['order_id'])
  end
end
