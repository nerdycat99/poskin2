# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Inventory::Adjustments', type: :request do
  let(:country) { Country.create(country: 'Australia', code: 'AUD') }
  let(:address) do
    Address.create(country_id: country.id, first_line: '100 The Road', second_line: nil, city: 'Sydney', state: 'NSW', postcode: '1234')
  end
  let(:supplier_name) { 'Supplier Ltd' }
  let(:supplier_email) { 'supplier@qwerty.com' }
  let(:tax_rate) { TaxRate.create(rate: '10', name: 'basic rate') }
  let(:supplier) { Supplier.create(name: supplier_name, email: supplier_email, phone: '123456789', address_id: address.id, tax_rate_id: tax_rate.id) }
  let(:accounting_code) { AccountingCode.create(name: 'ABC123', enabled: true, description: 'my accounting code') }
  let(:product) do
    supplier.products.create(accounting_code_id: accounting_code.id, title: 'my product', description: 'my product description', sku_code: '987999',
                             publish: true, markup: '50', cost_price: 10_099)
  end

  let(:variant) { product.variants.create }
  let(:quantity) { 2 }
  let(:adjustment_type) { 'received' }
  let(:user_id) { 1 }
  let(:create_stock_adjustment) { variant.stock_adjustments.create(quantity:, adjustment_type:, user_id:) }
  let(:good_params) { { stock_adjustment: { adjustment_type:, quantity:, user_id: } } }

  describe 'POST /inventory/suppliers/:supplier_id/products/:product_id/variants/:variant_id/adjustments' do
    context 'with good params' do
      it 'creates a new Stock Adjustment' do
        expect { post inventory_supplier_product_variant_adjustments_path(supplier.id, product.id, variant.id, params: good_params) }.to change {
                                                                                                                                           StockAdjustment.count
                                                                                                                                         }.by(1)
      end

      it 'creates a stock adjustment associated to the variant' do
        post inventory_supplier_product_variant_adjustments_path(supplier.id, product.id, variant.id, params: good_params)
        expect(variant.reload.stock_adjustments.count).to eq(1)
      end

      it 'redirects on successful creation of a stock adjustment' do
        post inventory_supplier_product_variant_adjustments_path(supplier.id, product.id, variant.id, params: good_params)
        expect(response.status).to eq(302)
      end

      it 'increments the stock count for the variant' do
        per_stock_level = variant.stock_count
        post inventory_supplier_product_variant_adjustments_path(supplier.id, product.id, variant.id, params: good_params)
        expect(variant.reload.stock_count).to eq(per_stock_level + quantity)
      end
    end
  end
end
