# frozen_string_literal: true

class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :existing_supplier, only: %i[edit update]

  def index
    @suppliers = Supplier.all.order(:name)
  end

  def new
    @supplier = Supplier.new
    @supplier.build_address
    @gst_rates = TaxRate.all
  end

  def edit; end

  def create
    @supplier = Supplier.new(supplier_params)
    return render(:new, status: :unprocessable_entity) unless @supplier.save

    redirect_to suppliers_path
  end

  def update
    if @existing_supplier.update(supplier_params)
      redirect_to suppliers_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def existing_supplier
    @existing_supplier = Supplier.find_by(id: params['id'])
  end

  def supplier_params
    params.require(:supplier).permit(:name, :email, :phone, :tax_rate_id, :address_id, :notes, :sales_tax_registered, :bank_account_name, :bank_acount_number, :bank_bsb, :bank_name,
                                     abn_number:, address_attributes: %i[country_id first_line second_line city state postcode])
  end
end
