# frozen_string_literal: true

require 'rails_helper'

describe Product do
  describe 'when saving guests' do
    let(:name) { 'joe satriani' }
    let(:email) { 'joe.satriani@email.com' }
    let(:phone) { %w[123 456] }
    let(:notes) { 'anything in here at all all is fine' }
    let(:country) { Country.create(country: 'Australia', code: 'AUD') }
    let(:address) do
      Address.create(country_id: country.id, first_line: '100 The Road', second_line: nil, city: 'Sydney', state: 'NSW', postcode: '1234')
    end
    let(:tax_rate) { TaxRate.create(rate: '10', name: 'basic rate') }
    let(:supplier) { Supplier.create(name:, email:, phone:, notes:, address_id: address.id, tax_rate_id: tax_rate.id) }

    let(:product_name) { 'my first product' }
    let(:description) { 'description of product' }
    let(:accounting_code) { AccountingCode.create(name: 'CONS001', enabled: true, description: 'consignment') }
    let(:accounting_code_id) { accounting_code.id }
    let(:sku) { '123456' }
    let(:markup) { '20' }
    let(:cost_price) { 12_345 }
    let(:create_product) do
      supplier.products.create(accounting_code_id:, title: product_name, description:, sku_code: sku,
                               publish: true, markup:, cost_price:)
    end

    context 'with valid attributes' do
      it 'is successful' do
        expect { create_product }.to change { Product.count }.by(1)
      end
    end

    context 'with invalid attributes' do
      context 'with missing title' do
        let(:product_name) { nil }
        it 'is unsuccessful' do
          expect { create_product }.to change { Product.count }.by(0)
        end
      end
      context 'with missing accounting_code_id' do
        let(:accounting_code_id) { nil }
        it 'is unsuccessful' do
          expect { create_product }.to change { Product.count }.by(0)
        end
      end
      context 'with invalid description' do
        let(:description) { nil }
        it 'is unsuccessful' do
          expect { create_product }.to change { Product.count }.by(0)
        end
      end
      context 'with missing sku code' do
        let(:sku) { nil }
        it 'is unsuccessful' do
          expect { create_product }.to change { Product.count }.by(0)
        end
      end
      context 'with missing markup' do
        let(:markup) { nil }
        it 'is unsuccessful' do
          expect { create_product }.to change { Product.count }.by(0)
        end
      end
      context 'with missing cost_price' do
        let(:cost_price) { nil }
        it 'is unsuccessful' do
          expect { create_product }.to change { Product.count }.by(0)
        end
      end
      context 'with zero cost_price' do
        let(:cost_price) { 0 }
        it 'is unsuccessful' do
          expect { create_product }.to change { Product.count }.by(0)
        end
      end
    end
  end
end
