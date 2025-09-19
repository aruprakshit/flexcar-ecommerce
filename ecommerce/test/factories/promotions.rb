FactoryBot.define do
  factory :promotion do
    sequence(:name) { |n| "Promotion #{n}" }
    promotion_type { :percentage }
    discount_value { 10 }
    start_time { 1.day.ago }
    end_time { 1.week.from_now }
    buy_quantity { 1 }
    get_quantity { 1 }
    get_discount_percentage { 100 }
    weight_threshold { 5.0 }
    weight_discount_percentage { 20 }
    promotionable { association :item }

    trait :flat_fee do
      promotion_type { :flat_fee }
      discount_value { 25 }
    end

    trait :percentage do
      promotion_type { :percentage }
      discount_value { 15 }
    end

    trait :bogo do
      promotion_type { :bogo }
      discount_value { 0 }
      buy_quantity { 2 }
      get_quantity { 1 }
      get_discount_percentage { 100 }
    end

    trait :weight_threshold do
      promotion_type { :weight_threshold }
      discount_value { 0 }
      weight_threshold { 5.0 }
      weight_discount_percentage { 20 }
    end

    trait :expired do
      start_time { 2.days.ago }
      end_time { 1.day.ago }
    end

    trait :future do
      start_time { 1.day.from_now }
      end_time { 1.week.from_now }
    end

    trait :no_end_time do
      end_time { nil }
    end
  end
end
