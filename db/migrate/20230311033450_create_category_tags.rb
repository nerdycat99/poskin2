class CreateCategoryTags < ActiveRecord::Migration[7.0]
  def change
    create_table :category_tags do |t|
      t.string :name, unique: true, null: false
      t.boolean :enabled, default: true
      t.timestamps
    end
  end
end
