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
FactoryBot.define do
  factory :account do
    balance_cents { 1000 }
    balance_currency { 'BRL' }
    name { 'Some Name' }
  end
end
