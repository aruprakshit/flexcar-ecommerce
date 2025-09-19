FactoryBot.define do
  factory :cart_item do
    cart { association :cart }
    item { association :item }
    promotion { association :promotion }
    quantity { Faker::Number.between(from: 1, to: 10) }
    final_price { Faker::Commerce.price }
  end
end
