class PromotionService
  def initialize(cart_item)
    @cart_item = cart_item
    @item = cart_item.item
    @quantity = cart_item.quantity
  end

  def calculate_best_promotion
    applicable_promotions = find_applicable_promotions
    return nil if applicable_promotions.empty?

    best_promotion = find_best_promotion(applicable_promotions)
    apply_promotion(best_promotion) if best_promotion
  end

  private

  def find_applicable_promotions
    promotions = []
    
    # Item-specific promotions
    promotions.concat(Promotion.active.for_item(@item))
    
    # Category promotions
    promotions.concat(Promotion.active.for_category(@item.category))
    
    # Brand promotions
    promotions.concat(Promotion.active.for_brand(@item.brand))
    
    promotions.select { |promotion| promotion_applicable?(promotion) }
  end

  def promotion_applicable?(promotion)
    case promotion.promotion_type
    when 'flat_fee'
      true
    when 'percentage'
      true
    when 'bogo'
      @quantity >= promotion.buy_quantity
    when 'weight_threshold'
      @item.by_weight? && @quantity >= promotion.weight_threshold
    else
      false
    end
  end

  def find_best_promotion(promotions)
    promotions.max_by { |promotion| calculate_discount_amount(promotion) }
  end

  def calculate_discount_amount(promotion)
    case promotion.promotion_type
    when 'flat_fee'
      promotion.discount_value
    when 'percentage'
      (@item.price * @quantity * promotion.discount_value / 100)
    when 'bogo'
      calculate_bogo_discount(promotion)
    when 'weight_threshold'
      (@item.price * @quantity * promotion.weight_discount_percentage / 100)
    else
      0
    end
  end

  def calculate_bogo_discount(promotion)
    eligible_sets = (@quantity / promotion.buy_quantity).floor
    get_items = eligible_sets * promotion.get_quantity
    
    if promotion.get_discount_percentage == 100
      # Free items - full discount
      get_items * @item.price
    else
      # Partial discount
      discount_per_item = @item.price * (promotion.get_discount_percentage / 100)
      get_items * discount_per_item
    end
  end

  def apply_promotion(promotion)
    discount_amount = calculate_discount_amount(promotion)
    final_price = (@item.price * @quantity) - discount_amount
    
    {
      promotion: promotion,
      original_price: @item.price * @quantity,
      discount_amount: discount_amount,
      final_price: [final_price, 0].max
    }
  end
end