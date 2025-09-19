class CartService
  def initialize(session_id)
    @session_id = session_id
    @cart = find_or_create_cart
  end

  def add_item(item_id, quantity)
    item = Item.find(item_id)
    cart_item = @cart.cart_items.find_or_initialize_by(item: item)
    
    if cart_item.persisted?
      cart_item.quantity += quantity
    else
      cart_item.quantity = quantity
    end

    # Calculate best promotion and final price
    promotion_result = PromotionService.new(cart_item).calculate_best_promotion
    
    if promotion_result
      cart_item.promotion = promotion_result[:promotion]
      cart_item.final_price = promotion_result[:final_price]
    else
      cart_item.promotion = nil
      cart_item.final_price = cart_item.calculate_final_price
    end

    cart_item.save!
    cart_item
  end

  def remove_item(item_id)
    @cart.cart_items.find_by(item_id: item_id)&.destroy
  end

  def update_item_quantity(item_id, quantity)
    cart_item = @cart.cart_items.find_by(item_id: item_id)
    return unless cart_item

    if quantity <= 0
      cart_item.destroy
    else
      cart_item.quantity = quantity
      
      # Recalculate promotion
      promotion_result = PromotionService.new(cart_item).calculate_best_promotion
      
      if promotion_result
        cart_item.promotion = promotion_result[:promotion]
        cart_item.final_price = promotion_result[:final_price]
      else
        cart_item.promotion = nil
        cart_item.final_price = cart_item.calculate_final_price
      end
      
      cart_item.save!
    end
  end

  def get_cart
    @cart
  end

  private

  def find_or_create_cart
    Cart.find_or_create_by(session_id: @session_id)
  end
end