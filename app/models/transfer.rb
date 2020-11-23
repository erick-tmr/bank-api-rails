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
class Transfer < ApplicationRecord
  belongs_to :source, class_name: 'Account', inverse_of: :source_transfers
  belongs_to :destination, class_name: 'Account', inverse_of: :destination_transfers

  monetize :value_cents, numericality: { greater_than: 0 }
  monetize :initial_balance_cents

  def as_json
    {
      id: id,
      initial_balance_cents: initial_balance.cents,
      initial_balance_humanized: initial_balance.format,
      value_cents: value.cents,
      value_humanized: value.format,
      destination_id: destination_id,
      source_id: source_id
    }
  end
end
