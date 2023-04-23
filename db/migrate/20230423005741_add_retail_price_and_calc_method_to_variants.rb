class AddRetailPriceAndCalcMethodToVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :variants, :retail_price, :integer
    add_column :variants, :price_calc_method, :integer
  end
end
