class AddBankingDetailsToSuppliers < ActiveRecord::Migration[7.0]
  def change
    add_column :suppliers, :bank_acount_name, :string
    add_column :suppliers, :bank_acount_number, :string
    add_column :suppliers, :bank_bsb, :string
    add_column :suppliers, :bank_name, :string
  end
end
