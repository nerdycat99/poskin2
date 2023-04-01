# frozen_string_literal: true

require 'rails_helper'

describe StockAdjustment do
  describe 'when saving stock adjustments' do
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
    let(:accounting_code) { AccountingCode.create(name: 'CONS001', enabled: true, description: 'consignment') }
    let(:accounting_code_id) { accounting_code.id }
    let(:product) do
      supplier.products.create(accounting_code_id: accounting_code.id, title: 'my product', description: 'my product description', sku_code: '987999',
                               publish: true, markup: '50', cost_price: 10_099)
    end

    let(:variant) { product.variants.create }
    let(:quantity) { 2 }
    let(:adjustment_type) { 'received' }
    let(:user_id) { 1 }
    let(:create_stock_adjustment) { variant.stock_adjustments.create(quantity:, adjustment_type:, user_id:) }

    context 'with valid attributes' do
      it 'is successful' do
        expect { create_stock_adjustment }.to change { StockAdjustment.count }.by(1)
      end

      context 'when the adjustment_type is received' do
        it 'adds to the variant stock_count' do
          create_stock_adjustment
          expect(variant.reload.stock_count).to eq(2)
        end
      end
      # received: 0, refunded: 1, purchased: 2, returned:
      context 'when the adjustment_type is refunded' do
        let(:adjustment_type) { 'refunded' }
        it 'adds to the variant stock_count' do
          create_stock_adjustment
          expect(variant.reload.stock_count).to eq(2)
        end
      end
      context 'when the adjustment_type is purchased' do
        let(:adjustment_type) { 'purchased' }
        let(:quantity) { 1 }
        it 'substracts from the variant stock_count' do
          variant.stock_adjustments.create(quantity: 2, adjustment_type: 'received', user_id: 1) #first set the count to 2 for stock
          create_stock_adjustment
          expect(variant.reload.stock_count).to eq(1)
        end
      end
      context 'when the adjustment_type is returned' do
        let(:adjustment_type) { 'returned' }
        let(:quantity) { 1 }
        it 'substracts from the variant stock_count' do
          variant.stock_adjustments.create(quantity: 2, adjustment_type: 'received', user_id: 1) #first set the count to 2 for stock
          create_stock_adjustment
          expect(variant.reload.stock_count).to eq(1)
        end
      end
    end

    context 'with invalid attributes' do
      context 'with missing quantity' do
        let(:quantity) { nil }
        it 'is unsuccessful' do
          expect { create_stock_adjustment }.to change { StockAdjustment.count }.by(0)
        end
      end
      context 'with negaive quantity' do
        let(:quantity) { -5 }
        it 'is unsuccessful' do
          expect { create_stock_adjustment }.to change { StockAdjustment.count }.by(0)
        end
      end
      context 'with invalid adjustment_type' do
        let(:adjustment_type) { 'something else' }
        xit 'is unsuccessful' do
          expect { create_stock_adjustment }.to change { StockAdjustment.count }.by(0)
        end
      end
      context 'with missing adjustment_type' do
        let(:adjustment_type) { nil }
        xit 'is unsuccessful' do
          expect { create_stock_adjustment }.to change { StockAdjustment.count }.by(0)
        end
      end
      context 'with missing user_id' do
        let(:user_id) { nil }
        it 'is unsuccessful' do
          expect { create_stock_adjustment }.to change { StockAdjustment.count }.by(0)
        end
      end
    end
  end
end
