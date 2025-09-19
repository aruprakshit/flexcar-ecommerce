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

  def calculate_final_price
    return subtotal unless promotion

    case promotion.promotion_type
    when 'percentage'
      subtotal * (1 - promotion.discount_value / 100.0)
    when 'flat_fee'
      [subtotal - promotion.discount_value, 0].max
    when 'bogo'
      # Simplified BOGO calculation - should use PromotionService for accurate calculation
      subtotal
    when 'weight_threshold'
      # Simplified weight threshold calculation - should use PromotionService for accurate calculation
      subtotal
    else
      subtotal
    end
  end

  def recalculate_final_price!
    self.final_price = calculate_final_price
    save!
  end

end
