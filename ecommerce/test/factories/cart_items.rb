FactoryBot.define do
  factory :cart_item do
    cart { association :cart }
    item { association :item }
    promotion { nil }
    quantity { 2 }
    final_price { 200.0 }

    trait :with_promotion do
      promotion { association :promotion }
    end

    trait :by_weight do
      item { association :item, :by_weight }
      quantity { 10.0 }
      final_price { 50.0 }
    end
  end
end
