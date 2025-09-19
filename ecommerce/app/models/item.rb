class Item < ApplicationRecord
  belongs_to :brand
  belongs_to :category
  
  has_many   :cart_items, dependent: :destroy
  has_many   :carts, through: :cart_items
  has_many   :promotions, as: :promotionable, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :sale_type, inclusion: { in: %w[by_weight by_quantity] }
  validates :brand_id, :category_id, presence: true

  enum :sale_type, { by_weight: 0, by_quantity: 1 }, validate: true
end
