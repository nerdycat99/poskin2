class AddAbnToSupplier < ActiveRecord::Migration[7.0]
  def change
    add_column :suppliers, :abn_number, :integer
  end
end
