class Item < ApplicationRecord
  belongs_to :brand
  belongs_to :category
  
  has_many   :cart_items, dependent: :destroy
  has_many   :carts, through: :cart_items
  has_many   :promotions, as: :promotionable, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :brand_id, :category_id, presence: true

  enum :sale_type, { by_weight: 0, by_quantity: 1 }, validate: true

  def by_weight?
    sale_type == 'by_weight'
  end

  def has_active_promotions?
    # Check if item has active promotions through any path:
    # 1. Direct item promotions
    # 2. Brand promotions  
    # 3. Category promotions
    promotions.active.any? || brand.promotions.active.any? || category.promotions.active.any?
  end

  def active_promotion_types
    types = []
    types << 'direct' if promotions.active.any?
    types << 'brand' if brand.promotions.active.any?
    types << 'category' if category.promotions.active.any?
    types
  end

  def calculate_discounted_price(quantity = 1)
    temp_cart_item = Struct.new(:item, :quantity).new(self, quantity)
    
    promotion_service = PromotionService.new(temp_cart_item)
    result = promotion_service.calculate_best_promotion
    
    return price unless result
    
    result[:final_price] / quantity
  end
end
