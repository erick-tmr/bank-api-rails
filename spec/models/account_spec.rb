# == Schema Information
#
# Table name: accounts
#
#  id               :bigint           not null, primary key
#  balance_cents    :integer          default(0), not null
#  balance_currency :string(255)      default("BRL"), not null
#  name             :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  context 'validations' do
    it 'validates the balance' do
      instance = described_class.new(balance: 'invalid')
      instance.validate

      expect(instance.errors.empty?).to eq(false)
      expect(instance.errors.messages[:balance]).to eq(['is not a number'])
    end

    it 'validates the name' do
      instance = described_class.new
      instance.validate

      expect(instance.errors.empty?).to eq(false)
      expect(instance.errors.messages[:name]).to eq(['can\'t be blank'])
    end

    it 'validates the id' do
      existing_account = create(:account)

      instance = described_class.new(id: existing_account.id)
      instance.validate

      expect(instance.errors.empty?).to eq(false)
      expect(instance.errors.messages[:id]).to eq(['already exists'])
    end
  end

  describe '#as_json' do
    it 'returns a hash as a json representation' do
      existing_account = create(:account)

      expect(existing_account.as_json[:id]).to eq(existing_account.id)
      expect(existing_account.as_json[:balance_cents]).to eq(existing_account.balance.cents)
      expect(existing_account.as_json[:balance_humanized]).to eq(existing_account.balance.format)
      expect(existing_account.as_json[:name]).to eq(existing_account.name)
    end
  end
end
