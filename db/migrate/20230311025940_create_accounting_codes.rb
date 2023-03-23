class CreateAccountingCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :accounting_codes do |t|
      t.string :name, unique: true, null: false
      t.boolean :enabled, default: true
      t.string :description
      t.timestamps
    end
  end
end
