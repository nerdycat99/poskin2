class CreateVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.string :sku_code
      t.string :barcode
      t.timestamps
    end
  end
end
