class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.integer :customer_id, null: true
      t.integer :state
      t.integer :payment_method, null: true
      t.string :payment_other_method
      t.integer :payment_amount
      t.string :adjustments
      t.boolean :delivery
      t.string  :notes
      t.string :first_name
      t.string :last_name
      t.string :email_address
      t.string :phone_number
      t.timestamps
    end
    add_index :orders, :customer_id
  end
end
