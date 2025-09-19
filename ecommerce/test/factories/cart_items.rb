FactoryBot.define do
  factory :cart_item do
    cart { association :cart }
    item { association :item }
    promotion { nil }
    quantity { 2 }

    # Calculate final_price based on item price and quantity
    final_price { item.price * quantity }

    trait :with_promotion do
      promotion { association :promotion }
      # Override final_price when promotion is present
      after(:build) do |cart_item|
        if cart_item.promotion && cart_item.item
          case cart_item.promotion.promotion_type
          when 'percentage'
            cart_item.final_price = cart_item.subtotal * (1 - cart_item.promotion.discount_value / 100.0)
          when 'flat_fee'
            cart_item.final_price = [cart_item.subtotal - cart_item.promotion.discount_value, 0].max
          when 'bogo'
            # Simplified BOGO calculation for factory
            cart_item.final_price = cart_item.subtotal
          when 'weight_threshold'
            # Simplified weight threshold calculation for factory
            cart_item.final_price = cart_item.subtotal
          end
        end
      end
    end

    trait :by_weight do
      item { association :item, :by_weight }
      quantity { 10.0 }
      final_price { item.price * 10.0 }
    end

    trait :by_quantity do
      item { association :item, :by_quantity }
      quantity { 3 }
      final_price { item.price * 3 }
    end

    trait :single_item do
      quantity { 1 }
      final_price { item.price }
    end

    trait :large_quantity do
      quantity { 100 }
      final_price { item.price * 100 }
    end
  end
end
