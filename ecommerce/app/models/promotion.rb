class Promotion < ApplicationRecord
  belongs_to :promotionable, polymorphic: true

  validates_with PromotionValidator

  validates :name, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :start_time, presence: true
  validates :buy_quantity, presence: true, if: :bogo?
  validates :get_quantity, presence: true, if: :bogo?
  validates :get_discount_percentage, presence: true, if: :bogo?
  validates :weight_threshold, presence: true, if: :weight_threshold?
  validates :weight_discount_percentage, presence: true, if: :weight_threshold?

  enum :promotion_type, { 
    flat_fee: 0, 
    percentage: 1, 
    bogo: 2, 
    weight_threshold: 3 
  }, validate: true
end
