class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.references :country, null: false, foreign_key: true
      t.string :first_line
      t.string :second_line
      t.string :city
      t.string :state
      t.string :postcode
      t.timestamps
    end
  end
end
