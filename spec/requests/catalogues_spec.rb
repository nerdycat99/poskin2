# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalogues', type: :request do
  let(:password_signup) { 'password' }
  let!(:user) do
    User.create(email: 'test@test.com', password: password_signup, password_confirmation: password_signup)
  end

  describe 'GET /api/v1/me' do
    context 'without successful authentication' do
      it 'redirects user to login' do
        get catalogue_index_path
        expect(response.status).to eq(302)
      end
      it 'does not show the catalogues page' do
        get catalogue_index_path
        expect(response.body).not_to include('Products & Variants')
      end
    end

    context 'with successful authentication' do
      before(:each) do
        allow_any_instance_of(CatalogueController).to receive(:authenticate_user!).and_return(true)
        allow_any_instance_of(CatalogueController).to receive(:current_user).and_return(user)
      end
      it 'returns a success response' do
        get catalogue_index_path
        expect(response).to be_successful
      end
      it 'shows the catalogue page' do
        get catalogue_index_path
        expect(response.body).to include('Products & Variants')
      end
    end
  end
end
