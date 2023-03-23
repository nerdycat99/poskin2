class CreateCategoryTagsProductsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :category_tags, :products do |t|
      t.index :category_tag_id
      t.index :product_id
    end
  end
end
