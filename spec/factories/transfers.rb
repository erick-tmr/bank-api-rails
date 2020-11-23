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
FactoryBot.define do
  factory :transfer do
    initial_balance_cents { 1000 }
    initial_balance_currency { 'BRL' }
    value_cents { 100 }
    value_currency { 'BRL' }
    destination { create(:account) }
    source { create(:account) }
  end
end
