class CreateReceipt < ActiveRecord::Migration[7.0]
  def change
    create_table :receipts do |t|
      t.references :order, null: false, foreign_key: true
      t.string :email_address
      t.string  :item_one_name
      t.string  :item_one_price_minus_tax
      t.string  :item_two_name
      t.string  :item_two_price_minus_tax
      t.string  :item_three_name
      t.string  :item_three_price_minus_tax
      t.string  :item_four_name
      t.string  :item_four_price_minus_tax
      t.string  :item_five_name
      t.string  :item_five_price_minus_tax
      t.string  :item_six_name
      t.string  :item_six_price_minus_tax
      t.timestamps
    end
  end
end
