class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :country
      t.string :code
      t.timestamps
    end
  end
end
