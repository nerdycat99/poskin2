# frozen_string_literal: true

class SuppliersController < ApplicationController
  def index
    @suppliers = Supplier.all
  end

  def new
    @supplier = Supplier.new
    @gst_rates = TaxRate.all
  end

  def create
    @supplier = Supplier.new(supplier_params)
    return render(:new, status: :unprocessable_entity) unless @supplier.save

    redirect_to suppliers_path
  end

  private

  def supplier_params
    params.require(:supplier).permit(:name, :email, :phone, :tax_rate_id, :address_id, :notes)
  end
end
