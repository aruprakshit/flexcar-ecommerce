FactoryBot.define do
  factory :cart do
    session_id { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
