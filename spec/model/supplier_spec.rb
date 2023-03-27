# frozen_string_literal: true

require 'rails_helper'

describe Supplier do
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
    let(:create_supplier) { Supplier.create(name:, email:, phone:, notes:, address_id: address.id, tax_rate_id: tax_rate.id) }

    context 'with valid attributes' do
      it 'is successful' do
        expect { create_supplier }.to change { Supplier.count }.by(1)
      end
    end

    context 'with invalid attributes' do
      context 'with missing name' do
        let(:name) { nil }
        it 'is unsuccessful' do
          expect { create_supplier }.to change { Supplier.count }.by(0)
        end
      end
      context 'with missing email' do
        let(:email) { nil }
        it 'is unsuccessful' do
          expect { create_supplier }.to change { Supplier.count }.by(0)
        end
      end
      context 'with invalid email' do
        let(:email) { 'somethingnotcorrect.place' }
        it 'is unsuccessful' do
          expect { create_supplier }.to change { Supplier.count }.by(0)
        end
      end
      context 'with missing phone numbers' do
        let(:phone) { nil }
        it 'is unsuccessful' do
          expect { create_supplier }.to change { Supplier.count }.by(0)
        end
      end
      context 'with empty phone numbers array' do
        let(:phone) { [] }
        it 'is unsuccessful' do
          expect { Supplier }.to change { Supplier.count }.by(0)
        end
      end
      context 'without an address' do
        let(:address) { nil }
        it 'is unsuccessful' do
          expect { Supplier }.to change { Supplier.count }.by(0)
        end
      end
      context 'without a tax rate' do
        let(:tax_rate) { nil }
        it 'is unsuccessful' do
          expect { Supplier }.to change { Supplier.count }.by(0)
        end
      end
    end
  end
end
