class AddIndexToCartItem < ActiveRecord::Migration[8.0]
  def change
    add_index :cart_items, [:cart_id, :item_id], unique: true, name: 'idx_ecommerce_0006'
  end
end
