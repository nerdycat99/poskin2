class CreateProductAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :product_attributes do |t|
      t.string :name
      t.string :value
      t.timestamps
    end
  end
end
