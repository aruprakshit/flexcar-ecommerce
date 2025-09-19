class AddIndexToCategory < ActiveRecord::Migration[8.0]
  def change
    add_index :categories, :name, unique: true, name: 'idx_ecommerce_0002'
  end
end
