# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalogue::Suppliers', type: :request do
  let(:password_signup) { 'password' }
  let!(:user) do
    User.create(email: 'test@test.com', password: password_signup, password_confirmation: password_signup)
  end
  let(:country) { Country.create(country: 'Australia', code: 'AUD') }
  let(:address) do
    Address.create(country_id: country.id, first_line: '100 The Road', second_line: nil, city: 'Sydney', state: 'NSW', postcode: '1234')
  end
  let(:supplier_name) { 'Supplier Ltd' }
  let(:supplier_email) { 'supplier@qwerty.com' }
  let(:tax_rate) { TaxRate.create(rate: '10', name: 'basic rate') }
  let(:supplier) { Supplier.create(name: supplier_name, email: supplier_email, phone: '123456789', address_id: address.id, tax_rate_id: tax_rate.id) }

  let(:good_params) { { supplier: { id: supplier.id } } }
  let(:bad_params) { { supplier: { id: 9999 } } }

  # index has a drop down of suppliers to select from
  describe 'GET /catalogue/suppliers' do
    context 'without successful authentication' do
      it 'redirects user to login' do
        get catalogue_suppliers_path
        expect(response.status).to eq(302)
      end
      it 'does not show the catalogues page' do
        get catalogue_suppliers_path
        expect(response.body).not_to include('Create or Edit Products and Variants for a Supplier')
      end
    end

    context 'with successful authentication' do
      before(:each) do
        allow_any_instance_of(Catalogue::SuppliersController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(Catalogue::SuppliersController).to receive(:current_user).and_return(user)
      end

      it 'shows a list of suppliers' do
        get catalogue_suppliers_path
        expect(response.status).to eq(200)
        expect(response.body).to include('Select the supplier then click next')
      end
    end
  end

  describe 'POST /catalogue/suppliers' do
    context 'without successful authentication' do
      it 'redirects user to login' do
        post catalogue_suppliers_path(params: good_params)
        expect(response.status).to eq(302)
      end
    end

    context 'with successful authentication' do
      before(:each) do
        allow_any_instance_of(Catalogue::SuppliersController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(Catalogue::SuppliersController).to receive(:current_user).and_return(user)
      end

      # if user selects a valid supplier they are taken to show for the supplier
      context 'with the id of an existing supplier' do
        it 'redirects to the show page' do
          post catalogue_suppliers_path(params: good_params)
          expect(response).to redirect_to(catalogue_supplier_path(supplier))
          expect(response.status).to eq(302)
        end
      end

      # if user does not select a valid supplier they remain on index and receive error
      context 'without the id of an existing supplier' do
        it 'directs the user back to the index page with error' do
          post catalogue_suppliers_path(params: bad_params)
          expect(response.body).to include('Please select a supplier from the list')
          expect(response.status).to eq(422)
        end
      end
    end
  end

  # show suppliuer and their products
  describe 'GET /catalogue/supplier/:id' do
    context 'without successful authentication' do
      it 'redirects user to login' do
        get catalogue_supplier_path(supplier)
        expect(response.status).to eq(302)
      end
    end

    context 'with successful authentication' do
      before(:each) do
        allow_any_instance_of(Catalogue::SuppliersController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(Catalogue::SuppliersController).to receive(:current_user).and_return(user)
      end

      it 'shows the supplier details' do
        get catalogue_supplier_path(supplier)
        expect(response.body).to include(supplier_name)
        expect(response.status).to eq(200)
      end

      context 'with products' do
        let(:product_name) { 'my first product' }
        let(:description) { 'description of product' }
        let(:accounting_code) { AccountingCode.create(name: 'CONS001', enabled: true, description: 'consignment') }
        let(:create_product) do
          supplier.products.create(accounting_code_id: accounting_code.id, title: product_name, description:, sku_code: '12345', barcode: '12345',
                                   publish: true, markup: '100', cost_price: 2000)
        end
        it 'shows the suppliers product' do
          create_product
          get catalogue_supplier_path(supplier)
          expect(response.body).to include(product_name)
          expect(response.body).to include(description)
        end
      end
      context 'without products' do
        # TO DO: once we have the formatted table
      end
    end
  end
end
