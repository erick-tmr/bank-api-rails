require 'rails_helper'

RSpec.describe CreateTransfer, type: :service do
  let(:params) { { source_id: source_account.id, destination_id: destination_account.id, value: 500 } }
  let(:source_account) { create(:account, balance: 1000) }
  let(:destination_account) { create(:account) }
  let(:instance) { described_class.new(params) }

  it 'creates the transfer' do
    instance.run

    last_transfer = Transfer.last

    expect(last_transfer).to_not be_nil
    expect(last_transfer.source_id).to eq(source_account.id)
    expect(last_transfer.destination_id).to eq(destination_account.id)
    expect(last_transfer.value.cents).to eq(50_000)
  end

  it 'sets the transfer initial balance' do
    instance.run

    last_transfer = Transfer.last

    expect(last_transfer.initial_balance.cents).to eq(source_account.balance.cents)
  end

  it 'debits the source account' do
    instance.run

    initial_balance = source_account.balance
    source_account.reload
    last_transfer = Transfer.last

    expect(source_account.balance).to eq(initial_balance - last_transfer.value)
  end

  it 'credits the destination account' do
    instance.run

    initial_balance = destination_account.balance
    destination_account.reload
    last_transfer = Transfer.last

    expect(destination_account.balance).to eq(initial_balance + last_transfer.value)
  end

  it 'returns the created transfer' do
    response = instance.run

    expect(response[:transfer]).to_not be_nil
    expect(response[:transfer].source_id).to eq(source_account.id)
    expect(response[:transfer].destination_id).to eq(destination_account.id)
    expect(response[:transfer].value.cents).to eq(50_000)
  end

  context 'with invalid params' do
    let(:params) { { source_id: source_account.id, destination_id: destination_account.id, value: 'a lot' } }

    it 'does not create the transfer' do
      instance.run

      expect(Transfer.any?).to eq(false)
    end

    it 'returns the errors' do
      response = instance.run

      expect(response[:errors]).to_not be_empty
      expect(response[:errors][:value]).to eq(['is not a number'])
    end

    context 'with source account insuficient balance' do
      let(:params) { { source_id: source_account.id, destination_id: destination_account.id, value: 500 } }
      let(:source_account) { create(:account, balance: 10) }

      it 'validates and returns the error' do
        response = instance.run

        expect(response[:errors]).to_not be_empty
        expect(response[:errors][:source]).to eq(['source account does not have enough balance'])
      end
    end
  end
end
