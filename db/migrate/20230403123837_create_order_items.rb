class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :variant_id
      t.integer :product_id
      t.integer :quantity
      t.integer :stock_adjustment_id
      t.timestamps
    end
    add_index :order_items, :variant_id
    add_index :order_items, :product_id
    add_index :order_items, :stock_adjustment_id
  end
end
