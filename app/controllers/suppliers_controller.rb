# frozen_string_literal: true

class SuppliersController < ApplicationController
  before_action :existing_supplier, only: [:edit, :update]

  def index
    @suppliers = Supplier.all.order(:name)
  end

  def new
    @supplier = Supplier.new
    @supplier.build_address
    @gst_rates = TaxRate.all
  end

  def edit
  end

  def update
    if @existing_supplier.update(supplier_params)
      redirect_to suppliers_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @supplier = Supplier.new(supplier_params)
    return render(:new, status: :unprocessable_entity) unless @supplier.save

    redirect_to suppliers_path
  end

  private

  def existing_supplier
    @existing_supplier = Supplier.find_by(id: params['id'])
  end

  def supplier_params
    params.require(:supplier).permit(:name, :email, :phone, :tax_rate_id, :address_id, :notes, address_attributes: [:country_id, :first_line, :second_line, :city, :state, :postcode])
  end
end
