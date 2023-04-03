class CreateStockAdjustments < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_adjustments do |t|
      t.references :variant, null: false, foreign_key: true
      t.integer :quantity
      t.integer :adjustment_type, null: false
      t.integer :user_id
      t.timestamps
    end
  end
end
