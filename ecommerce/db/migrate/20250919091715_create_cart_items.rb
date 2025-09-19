class CreateCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_items, id: :uuid do |t|
      t.references :cart, null: false, foreign_key: true, type: :uuid
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.references :promotion, null: true, foreign_key: true, type: :uuid
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.decimal :final_price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
