class AddIndexToPromotion < ActiveRecord::Migration[8.0]
  def change
    add_index :promotions, [:promotionable_type, :promotionable_id], name: 'idx_ecommerce_0003'
    add_index :promotions, [:start_time, :end_time], name: 'idx_ecommerce_0004'
  end
end
