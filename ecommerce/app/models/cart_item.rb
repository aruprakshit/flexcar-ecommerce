class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :item
  belongs_to :promotion, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :final_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :item_id, uniqueness: { scope: :cart_id }

  def subtotal
    item.price * quantity
  end

  def weight
    return quantity if item.by_weight?
    0
  end
end
