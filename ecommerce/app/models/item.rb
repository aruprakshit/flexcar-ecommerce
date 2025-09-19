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

  def by_weight?
    sale_type == 'by_weight'
  end

  def calculate_discounted_price(quantity = 1)
    # Find the best available promotion for this item
    best_promotion = find_best_available_promotion(quantity)
    
    return price unless best_promotion
    
    # Calculate discounted price based on promotion type
    case best_promotion.promotion_type
    when 'flat_fee'
      [price - best_promotion.discount_value, 0].max
    when 'percentage'
      price * (1 - best_promotion.discount_value / 100.0)
    when 'bogo'
      calculate_bogo_price(quantity, best_promotion)
    when 'weight_threshold'
      if by_weight? && quantity >= best_promotion.weight_threshold
        price * (1 - best_promotion.weight_discount_percentage / 100.0)
      else
        price
      end
    else
      price
    end
  end

  private

  def find_best_available_promotion(quantity)
    # Get all applicable promotions for this item
    applicable_promotions = []
    
    # Item-specific promotions
    applicable_promotions.concat(promotions.active)
    
    # Category promotions
    applicable_promotions.concat(category.promotions.active)
    
    # Brand promotions
    applicable_promotions.concat(brand.promotions.active)
    
    # Filter by applicability based on quantity and item type
    applicable_promotions.select! { |promotion| promotion_applicable?(promotion, quantity) }
    
    # Return the promotion with the highest discount
    applicable_promotions.max_by { |promotion| calculate_discount_amount(promotion, quantity) }
  end

  def promotion_applicable?(promotion, quantity)
    case promotion.promotion_type
    when 'flat_fee', 'percentage'
      true
    when 'bogo'
      quantity >= promotion.buy_quantity
    when 'weight_threshold'
      by_weight? && quantity >= promotion.weight_threshold
    else
      false
    end
  end

  def calculate_discount_amount(promotion, quantity)
    case promotion.promotion_type
    when 'flat_fee'
      promotion.discount_value
    when 'percentage'
      (price * quantity * promotion.discount_value / 100)
    when 'bogo'
      calculate_bogo_discount_amount(quantity, promotion)
    when 'weight_threshold'
      (price * quantity * promotion.weight_discount_percentage / 100)
    else
      0
    end
  end

  def calculate_bogo_price(quantity, promotion)
    # For display purposes, calculate the effective price per unit
    eligible_sets = (quantity / promotion.buy_quantity).floor
    get_items = eligible_sets * promotion.get_quantity
    total_items = quantity
    
    if promotion.get_discount_percentage == 100
      # Free items - calculate effective price
      paid_items = total_items - get_items
      return 0 if paid_items <= 0
      (price * paid_items) / total_items
    else
      # Partial discount - calculate effective price
      discount_per_item = price * (promotion.get_discount_percentage / 100)
      total_cost = (price * total_items) - (get_items * discount_per_item)
      total_cost / total_items
    end
  end

  def calculate_bogo_discount_amount(quantity, promotion)
    eligible_sets = (quantity / promotion.buy_quantity).floor
    get_items = eligible_sets * promotion.get_quantity
    
    if promotion.get_discount_percentage == 100
      # Free items - full discount
      get_items * price
    else
      # Partial discount
      discount_per_item = price * (promotion.get_discount_percentage / 100)
      get_items * discount_per_item
    end
  end
end
