# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalogue::Variants', type: :request do
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
  let(:supplier) do
    Supplier.create(name: supplier_name, email: supplier_email, phone: '123456789', address_id: address.id, tax_rate_id: tax_rate.id,
                    sales_tax_registered: true)
  end
  let(:accounting_code) { AccountingCode.create(name: 'ABC123', enabled: true, description: 'my accounting code') }
  let(:product) do
    supplier.products.create(accounting_code_id: accounting_code.id, title: 'my product', description: 'my product description', sku_code: '987999',
                             publish: true, markup: '50', cost_price: 10_099, retail_price: 0, price_calc_method: 0)
  end

  let(:attr_1) { ProductAttribute.create(name: 'colour', value: 'red') }
  let(:attr_2) { ProductAttribute.create(name: 'size', value: 'small') }
  let(:attr_3) { ProductAttribute.create(name: 'colour', value: 'blue') }
  let(:attr_4) { ProductAttribute.create(name: 'size', value: 'large') }

  let(:good_params) do
    { variant: { quantity: 0,
                 product_attributes_variants_attributes: { '0': { product_attribute_id: attr_1.id }, '1': { product_attribute_id: attr_2.id } } } }
  end
  let(:bad_params) { { supplier: { id: 9999 } } }

  # index has a drop down of suppliers to select from
  describe 'POST /catalogue/supplier/:id/product/:id/variants' do
    context 'without successful authentication' do
      it 'redirects user to login' do
        post catalogue_supplier_products_path(supplier.id), params: good_params
        expect(response.status).to eq(302)
      end
    end

    context 'with successful authentication' do
      before(:each) do
        allow_any_instance_of(Catalogue::VariantsController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(Catalogue::VariantsController).to receive(:current_user).and_return(user)
      end

      context 'with good params' do
        it 'creates a new variant' do
          expect { post catalogue_supplier_product_variants_path(supplier.id, product.id, params: good_params) }.to change { Variant.count }.by(1)
        end

        it 'creates a variant associated to the product' do
          post catalogue_supplier_product_variants_path(supplier.id, product.id, params: good_params)
          expect(product.reload.variants.count).to eq(1)
        end

        it 'redirects on successful creation of a variant' do
          post catalogue_supplier_product_variants_path(supplier.id, product.id, params: good_params)
          expect(response.status).to eq(302)
        end

        it 'creates a variant that is small and red' do
          post catalogue_supplier_product_variants_path(supplier.id, product.id, params: good_params)
          expect(product.reload.variants.first.display_characteristics).to include('Red')
          expect(product.reload.variants.first.display_characteristics).to include('Small')
        end
      end
    end
  end
end
