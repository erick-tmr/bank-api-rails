require 'rails_helper'

RSpec.describe CreateAccount, type: :service do
  let(:params) { { balance: 300, name: 'Person Name' } }
  let(:instance) { described_class.new(params) }

  it 'creates the account' do
    instance.run

    last_account = Account.last

    expect(last_account).to_not be_nil
    expect(last_account.balance.cents).to eq(30_000)
    expect(last_account.name).to eq(params[:name])
  end

  it 'generates the token' do
    response = instance.run
    decoded_token = JsonWebToken.decode(token: response[:token])

    expect(response[:token]).to_not be_nil
    expect(decoded_token[:payload][:account_id]).to eq(response[:account].id)
  end

  it 'returns the created account' do
    response = instance.run

    expect(response[:account]).to_not be_nil
    expect(response[:account].balance.cents).to eq(30_000)
    expect(response[:account].name).to eq(params[:name])
  end

  context 'with invalid params' do
    let(:params) { { balance: 'invalid', name: 'Person Name' } }

    it 'does not creates the account' do
      instance.run

      expect(Account.any?).to eq(false)
    end

    it 'returns the errors' do
      response = instance.run

      expect(response[:errors]).to_not be_empty
      expect(response[:errors][:balance]).to eq(['is not a number'])
    end
  end
end
