class AddAdjustmentAndDeliveryAmountsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :adjustment_amount, :integer
    add_column :orders, :delivery_amount, :integer
  end
end
