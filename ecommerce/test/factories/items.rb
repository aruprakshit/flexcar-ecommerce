FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    price { Faker::Commerce.price }
    sale_type { :by_weight }
    brand { association :brand }
    category { association :category }
  end
end
