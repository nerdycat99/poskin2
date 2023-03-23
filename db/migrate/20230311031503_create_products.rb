class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :accounting_code, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.text :notes
      t.string :sku_code
      t.string :barcode
      t.boolean :publish, default: false
      t.string :markup
      t.integer :cost_price
      t.timestamps
    end
  end
end
