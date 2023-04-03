# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Suppliers', type: :request do
  let(:password_signup) { 'password' }
  let!(:user) do
    User.create(email: "test@test.com", password: password_signup, password_confirmation: password_signup)
  end
  let(:country) { Country.create(country: 'Australia', code: 'AUD') }
  let(:address) do
    Address.create(country_id: country.id, first_line: '100 The Road', second_line: nil, city: 'Sydney', state: 'NSW', postcode: '1234')
  end
  let(:tax_rate) { TaxRate.create(rate: '10', name: 'basic rate') }
  let(:good_params) do
    {
      supplier: {
        name: 'Mr Supplier', email: 'qwerty@werty.com', phone: '0123456789', tax_rate_id: tax_rate.id, address_id: address.id
      }
    }
  end
  let(:bad_params) do
    {
      supplier: {
        name: 'Mr Supplier', email: 'qwertywerty.com', phone: '0123456789', tax_rate_id: tax_rate.id, address_id: address.id
      }
    }
  end

  describe 'POST /suppliers' do
    context 'without successful authentication' do
      it 'redirects user to login' do
        post suppliers_path(params: good_params)
        expect(response.status).to eq(302)
      end
    end

    context 'with successful authentication' do
      before(:each) do
        allow_any_instance_of(SuppliersController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(SuppliersController).to receive(:current_user).and_return(user)
      end
      context 'with good params' do
        it 'redirects the user' do
          post suppliers_path(params: good_params)
          expect(response).to redirect_to(suppliers_path)
          expect(response.status).to eq(302)
        end
        it 'creats a new supplier' do
          expect { post suppliers_path(params: good_params) }.to change { Supplier.count }.by(1)
        end
      end

      context 'with bad params' do
        it 'directs the user back to the new page with error' do
          post suppliers_path(params: bad_params)
          expect(response.body).to include('Email is invalid')
          expect(response.status).to eq(422)
        end
        it 'creats a new supplier' do
          expect { post suppliers_path(params: bad_params) }.to change { Supplier.count }.by(0)
        end
      end
    end
  end
end
