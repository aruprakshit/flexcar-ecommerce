FactoryBot.define do
  factory :cart do
    sequence(:session_id) { |n| "session_#{n}_#{SecureRandom.hex(4)}" }
  end
end
