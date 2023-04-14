class AddRetailPriceAndPriceCalcMethodToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :retail_price, :integer
    add_column :products, :price_calc_method, :integer
  end
end
