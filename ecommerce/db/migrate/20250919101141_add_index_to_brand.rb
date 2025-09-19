class AddIndexToBrand < ActiveRecord::Migration[8.0]
  def change
    add_index :brands, :name, unique: true, name: 'idx_ecommerce_0001'
  end
end
