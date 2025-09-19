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
      after(:build) do |cart_item|
        cart_item.final_price = cart_item.calculate_final_price
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
