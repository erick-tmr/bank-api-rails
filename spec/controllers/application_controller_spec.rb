require 'rails_helper'

RSpec.describe V1::AccountsController, type: :controller do
  let(:json) { JSON.parse(response.body).with_indifferent_access }
  let(:account) { create(:account) }

  describe 'actions protection' do
    context 'without token in the Authorization header' do
      before do
        get :show, params: { id: account.id }
      end

      it 'does not authorize' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error' do
        expect(json[:errors]).to eq({ 'token' => ['Invalid token.'] })
      end
    end

    context 'with Authorization header set with a valid token' do
      before do
        set_jwt_header(account.id)

        get :show, params: { id: account.id }
      end

      it 'permits the access to the action' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with an invalid token' do
      before do
        controller.request.headers['Authorization'] = 'Bearer not.valid.token'

        get :show, params: { id: account.id }
      end

      it 'returns invalid token error message' do
        expect(json[:errors]).to eq({ 'token' => ['Invalid token.'] })
      end

      it 'does not authorize' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with an expired token' do
      before do
        set_jwt_header(account.id, Time.now.to_i)

        get :show, params: { id: account.id }
      end

      it 'does not authorize' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns expired token error message' do
        expect(json[:errors]).to eq({ 'token' => ['Expired token.'] })
      end
    end
  end
end
