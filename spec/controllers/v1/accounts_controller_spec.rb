require 'rails_helper'

RSpec.describe V1::AccountsController, type: :controller do
  let(:json) { JSON.parse(response.body).with_indifferent_access }

  describe 'GET show' do
    let(:account) { create(:account) }
    let(:account_id) { account.id }

    before do |example|
      unless example.metadata[:skip_before]
        set_jwt_header(account.id)

        get :show, params: { id: account_id }
      end
    end

    it 'is protect by authentication', skip_before: true do
      get :show, params: { id: account_id }

      expect(json[:errors][:token]).to eq(['Invalid token.'])
    end

    it 'returns the requested account' do
      expect(json[:account]).to eq(account.as_json.stringify_keys)
    end

    it 'returns http status ok' do
      expect(response).to have_http_status(:ok)
    end

    context 'with invalid account id' do
      let(:account_id) { account.id + 1 }

      it 'returns errors' do
        expect(json[:errors]).to_not be_empty
        expect(json[:errors][:account]).to eq(["Account with id #{account_id} does not exists"])
      end

      it 'returns http status not_found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST create' do
    let(:params) { { account: { balance: balance, name: 'Some Name' } } }
    let(:balance) { 100 }

    before do
      post :create, params: params
    end

    it 'creates the account' do
      last_account = Account.last

      expect(last_account).to_not be_nil
      expect(last_account.name).to eq(params[:account][:name])
      expect(last_account.balance.cents).to eq(10_000)
    end

    it 'returns the generated token' do
      expect(json[:token]).to_not be_nil
    end

    it 'returns the created account' do
      expect(json[:account]).to_not be_nil
    end

    it 'returns http status created' do
      expect(response).to have_http_status(:created)
    end

    context 'with invalid params' do
      let(:params) { { account: { balance: 'mil', name: 'Some Name' } } }

      it 'returns http status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors' do
        expect(json[:errors]).to_not be_nil
        expect(json[:errors][:balance]).to eq(['is not a number'])
      end
    end

    context 'with negative balance' do
      let(:balance) { -100 }

      it 'creates the account' do
        last_account = Account.last

        expect(last_account).to_not be_nil
        expect(last_account.name).to eq(params[:account][:name])
        expect(last_account.balance.cents).to eq(-10_000)
      end
    end

    context 'with balance with more then 2 digits after the decimal point' do
      let(:balance) { '10,2345' }

      it 'ignores the extra digits' do
        expect(json[:account][:balance_cents]).to eq(1023)
      end
    end
  end
end
