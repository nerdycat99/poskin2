class CreateSuppliers < ActiveRecord::Migration[7.0]
  def change
    create_table :suppliers do |t|
      t.references :address, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.json :phone
      t.text :notes
      t.bigint :tax_rate_id,
      t.timestamps
    end
  end
end
