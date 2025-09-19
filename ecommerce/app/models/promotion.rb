class Promotion < ApplicationRecord
  belongs_to :promotionable, polymorphic: true

  validates_with PromotionValidator

  validates :name, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }, unless: :bogo_or_weight_threshold?
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


  scope :active, -> { where('start_time <= ? AND (end_time IS NULL OR end_time >= ?)', Time.current, Time.current) }
  scope :for_item, ->(item) { where(promotionable: item) }
  scope :for_category, ->(category) { where(promotionable: category) }
  scope :for_brand, ->(brand) { where(promotionable: brand) }

  def bogo?
    promotion_type == 'bogo'
  end

  def weight_threshold?
    promotion_type == 'weight_threshold'
  end

  def bogo_or_weight_threshold?
    bogo? || weight_threshold?
  end
end
