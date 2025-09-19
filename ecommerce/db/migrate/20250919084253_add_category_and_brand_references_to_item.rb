class AddCategoryAndBrandReferencesToItem < ActiveRecord::Migration[8.0]
  def change
    add_reference :items, :brand, type: :uuid, foreign_key: true, null: false
    add_reference :items, :category, type: :uuid, foreign_key: true, null: false
  end
end
