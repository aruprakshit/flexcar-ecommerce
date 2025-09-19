FactoryBot.define do
  factory :promotion do
    name { Faker::Commerce.promotion_name }
    promotion_type { :percentage }
    discount_value { Faker::Commerce.price }
    start_time { Faker::Time.between(from: DateTime.now, to: 1.week.from_now) }
    end_time { Faker::Time.between(from: DateTime.now, to: 1.week.from_now) }
    buy_quantity { 1 }
    get_quantity { 1 }
    get_discount_percentage { Faker::Commerce.price }
    weight_threshold { Faker::Commerce.price }
    weight_discount_percentage { Faker::Commerce.price }
    promotionable { association :item }
  end
end
