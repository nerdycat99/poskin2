# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalogue::Products', type: :request do
  let(:password_signup) { 'password' }
  let!(:user) do
    User.create(email: 'test@test.com', password: password_signup, password_confirmation: password_signup)
  end
  let(:country) { Country.create(country: 'Australia', code: 'AUD') }
  let(:address) do
    Address.create(country_id: country.id, first_line: '100 The Road', second_line: nil, city: 'Sydney', state: 'NSW', postcode: '1234')
  end
  let(:tax_rate) { TaxRate.create(rate: '10', name: 'basic rate') }

  let(:name) { 'joe satriani' }
  let(:email) { 'joe.satriani@email.com' }
  let(:phone) { %w[123 456] }
  let(:notes) { 'anything in here at all all is fine' }
  let(:country) { Country.create(country: 'Australia', code: 'AUD') }
  let(:address) do
    Address.create(country_id: country.id, first_line: '100 The Road', second_line: nil, city: 'Sydney', state: 'NSW', postcode: '1234')
  end
  let(:tax_rate) { TaxRate.create(rate: '10', name: 'basic rate') }
  let(:supplier) { Supplier.create(name:, email:, phone:, notes:, address_id: address.id, tax_rate_id: tax_rate.id, sales_tax_registered: true) }
  let(:accounting_code) { AccountingCode.create(name: 'CONS001', enabled: true, description: 'consignment') }

  let(:good_params) do
    {
      product: {
        title: 'My Product', description: 'My product description', sku_code: '987654', publish: 'Yes', cost_price: 10_000, markup: 100, retail_price: 0, price_calc_method: 0, accounting_code_id: accounting_code.id
      }
    }
  end

  let(:bad_params) do
    {
      product: {
        title: 'My Product', description: 'My product description', sku_code: '987654', publish: 'Yes', cost_price: 10_000, markup: 100, retail_price: 0, price_calc_method: 0, accounting_code_id: nil
      }
    }
  end

  describe 'POST /catalogue/supplier/products' do
    context 'without successful authentication' do
      it 'redirects user to login' do
        post catalogue_supplier_products_path(supplier.id), params: good_params
        expect(response.status).to eq(302)
      end
      it 'does not show the catalogues page' do
        get catalogue_suppliers_path
        expect(response.body).not_to include('Create a product for')
      end
    end

    context 'with successful authentication' do
      before(:each) do
        allow_any_instance_of(Catalogue::ProductsController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(Catalogue::ProductsController).to receive(:current_user).and_return(user)
      end
      context 'with good params' do
        it 'redirects the user' do
          post catalogue_supplier_products_path(supplier.id), params: good_params
          expect(response).to redirect_to(catalogue_supplier_path(supplier.id))
          expect(response.status).to eq(302)
        end
        it 'creates a new supplier' do
          expect { post catalogue_supplier_products_path(supplier.id), params: good_params }.to change { Product.count }.by(1)
        end
      end

      context 'with bad params' do
        it 'directs the user back to the new page with error' do
          post catalogue_supplier_products_path(supplier.id), params: bad_params
          expect(response.body).to include('Accounting code can&#39;t be blank')
          expect(response.status).to eq(422)
        end
        it 'creats a new supplier' do
          expect { post catalogue_supplier_products_path(supplier.id), params: bad_params }.to change { Product.count }.by(0)
        end
      end
    end
  end
end
