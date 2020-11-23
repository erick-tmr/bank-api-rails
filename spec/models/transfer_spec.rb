# == Schema Information
#
# Table name: transfers
#
#  id                       :bigint           not null, primary key
#  initial_balance_cents    :integer          default(0), not null
#  initial_balance_currency :string(255)      default("BRL"), not null
#  value_cents              :integer          default(0), not null
#  value_currency           :string(255)      default("BRL"), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  destination_id           :bigint           not null
#  source_id                :bigint           not null
#
# Indexes
#
#  index_transfers_on_destination_id  (destination_id)
#  index_transfers_on_source_id       (source_id)
#
# Foreign Keys
#
#  fk_rails_...  (destination_id => accounts.id)
#  fk_rails_...  (source_id => accounts.id)
#
require 'rails_helper'

RSpec.describe Transfer, type: :model do
  context 'validations' do
    it 'validates the value' do
      [
        ['invalid', 'is not a number'],
        [0, 'must be greater than 0'],
        [-5, 'must be greater than 0']
      ].each do |params|
        instance = described_class.new(value: params[0])

        instance.validate

        expect(instance.errors.empty?).to eq(false)
        expect(instance.errors.messages[:value]).to eq([params[1]])
      end
    end

    it 'validates the source_id' do
      existing_account = create(:account)

      instance = described_class.new(source_id: existing_account.id + 1)

      instance.validate

      expect(instance.errors.empty?).to eq(false)
      expect(instance.errors.messages[:source]).to eq(['source account id doest not exists'])
    end

    it 'validates the destination_id' do
      existing_account = create(:account)

      instance = described_class.new(destination_id: existing_account.id + 1)

      instance.validate

      expect(instance.errors.empty?).to eq(false)
      expect(instance.errors.messages[:destination]).to eq(['destination account id doest not exists'])
    end

    it 'validates initial_balance' do
      instance = described_class.new(initial_balance: 'invalid')

      instance.validate
      expect(instance.errors.empty?).to eq(false)
      expect(instance.errors.messages[:initial_balance]).to eq(['is not a number'])
    end
  end

  describe '#as_json' do
    it 'returns a hash as a json representation' do
      existing_transfer = create(:transfer)

      expect(existing_transfer.as_json[:id]).to eq(existing_transfer.id)
      expect(existing_transfer.as_json[:initial_balance_cents]).to eq(existing_transfer.initial_balance.cents)
      expect(existing_transfer.as_json[:initial_balance_humanized]).to eq(existing_transfer.initial_balance.format)
      expect(existing_transfer.as_json[:value_cents]).to eq(existing_transfer.value.cents)
      expect(existing_transfer.as_json[:value_humanized]).to eq(existing_transfer.value.format)
      expect(existing_transfer.as_json[:destination_id]).to eq(existing_transfer.destination_id)
      expect(existing_transfer.as_json[:source_id]).to eq(existing_transfer.source_id)
    end
  end
end
