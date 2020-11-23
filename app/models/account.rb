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
class Account < ApplicationRecord
  has_many :source_transfers, class_name: 'Transfer',
                              dependent: :destroy, foreign_key: :source_id, inverse_of: :source
  has_many :destination_transfers, class_name: 'Transfer',
                                   dependent: :destroy, foreign_key: :destination_id, inverse_of: :destination

  monetize :balance_cents

  validates :name, presence: true

  validate :unique_id, if: :new_record?

  def as_json
    {
      id: id,
      balance_cents: balance.cents,
      balance_humanized: balance.format,
      name: name
    }
  end

  private

  def unique_id
    errors.add(:id, 'already exists') if self.class.exists?(id: id)
  end
end
