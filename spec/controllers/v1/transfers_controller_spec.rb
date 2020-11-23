require 'rails_helper'

RSpec.describe V1::TransfersController, type: :controller do
  let(:json) { JSON.parse(response.body).with_indifferent_access }

  describe 'POST create' do
    let(:params) { { transfer: transfer_params } }
    let(:transfer_params) { { source_id: source_id, destination_id: destination_id, value: value } }
    let(:source) { create(:account, balance: 1000) }
    let(:destination) { create(:account) }
    let(:source_id) { source.id }
    let(:destination_id) { destination.id }
    let(:value) { 10 }

    before do |example|
      unless example.metadata[:skip_before]
        set_jwt_header(source.id)

        post :create, params: params
      end
    end

    it 'is protect by authentication', skip_before: true do
      post :create, params: params

      expect(json[:errors][:token]).to eq(['Invalid token.'])
    end

    it 'creates the transfer' do
      last_transfer = Transfer.last

      expect(last_transfer).to_not be_nil
      expect(last_transfer.source_id).to eq(source_id)
      expect(last_transfer.destination_id).to eq(destination_id)
      expect(last_transfer.value.cents).to eq(1000)
    end

    it 'returns the created transfer' do
      expect(json[:transfer]).to_not be_nil
    end

    it 'returns http status created' do
      expect(response).to have_http_status(:created)
    end

    context 'with value with more then 2 digits after the decimal point' do
      let(:value) { '10,2345' }

      it 'ignores the extra digits' do
        expect(json[:transfer][:value_cents]).to eq(1023)
      end
    end

    context 'with invalid params' do
      let(:value) { -10 }

      it 'returns http status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors' do
        expect(json[:errors]).to_not be_nil
        expect(json[:errors][:value]).to eq(['must be greater than 0'])
      end
    end
  end
end
