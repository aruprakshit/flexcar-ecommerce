class CreatePromotions < ActiveRecord::Migration[8.0]
  def change
    create_table :promotions, id: :uuid do |t|
      t.string :name
      t.integer :promotion_type
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.references :promotionable, polymorphic: true, null: false, type: :uuid

      # BOGO specific fields
      t.integer :buy_quantity
      t.integer :get_quantity
      t.decimal :get_discount_percentage, precision: 5, scale: 2

      # Weight threshold specific fields
      t.decimal :weight_threshold, precision: 10, scale: 2
      t.decimal :weight_discount_percentage, precision: 5, scale: 2

      t.timestamps
    end
  end
end
