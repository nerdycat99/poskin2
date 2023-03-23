class CreateVariantProductAttributesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :variants, :product_attributes do |t|
      t.index :variant_id
      t.index :product_attribute_id
    end
  end
end
