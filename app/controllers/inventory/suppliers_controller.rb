# frozen_string_literal: true

class Inventory::SuppliersController < ApplicationController
  before_action :supplier, only: %i[index create]

  def index; end

  def show
    @supplier = existing_supplier(id: params['id'])
    @products = @supplier.products
  end

  def create
    if existing_supplier.present?
      redirect_to inventory_supplier_path(existing_supplier.id)
    else
      flash.now.alert = 'Please select a supplier from the list'
      render(:index, status: :unprocessable_entity)
    end
  end

  private

  def supplier
    @supplier ||= Supplier.new
  end

  def existing_supplier(id: nil)
    supplier_id = id || supplier_params[:id]
    @existing_supplier = Supplier.find_by(id: supplier_id) if supplier_id.present?
  end

  def supplier_params
    params.require(:supplier).permit(:id)
  end
end
