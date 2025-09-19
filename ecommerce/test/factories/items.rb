FactoryBot.define do
  factory :item do
    name { "Product #{Faker::Number.between(from: 1, to: 100)}" }
    description { Faker::Lorem.sentence }
    price { 100.0 }
    sale_type { :by_quantity }
    brand { association :brand }
    category { association :category }

    trait :by_weight do
      sale_type { :by_weight }
      price { 5.0 }
    end

    trait :by_quantity do
      sale_type { :by_quantity }
      price { 100.0 }
    end
  end
end
