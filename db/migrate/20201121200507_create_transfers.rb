class CreateTransfers < ActiveRecord::Migration[6.0]
  def change
    create_table :transfers do |t|
      t.references :source, index: true, foreign_key: { to_table: :accounts }, null: false
      t.references :destination, index: true, foreign_key: { to_table: :accounts }, null: false
      t.monetize :value
      t.monetize :initial_balance

      t.timestamps
    end
  end
end
