class AddOrderIdToStockAdjustments < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_adjustments, :order_id, :integer
  end
end
