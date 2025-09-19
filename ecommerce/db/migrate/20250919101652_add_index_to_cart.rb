class AddIndexToCart < ActiveRecord::Migration[8.0]
  def change
    add_index :carts, :session_id, unique: true, name: 'idx_ecommerce_0005'
  end
end
