class PromotionValidator < ActiveModel::Validator
  def validate(record)
    case record.promotion_type
    when 'bogo'
      validate_bogo_promotion(record)
    when 'weight_threshold'
      validate_weight_threshold_promotion(record)
    end
  end

  private

  def validate_bogo_promotion(record)
    if record.buy_quantity.blank? || record.buy_quantity <= 0
      record.errors.add(:buy_quantity, :bogo_required)
    end
    
    if record.get_quantity.blank? || record.get_quantity <= 0
      record.errors.add(:get_quantity, :bogo_required)
    end
    
    if record.get_discount_percentage.blank? || record.get_discount_percentage < 0 || record.get_discount_percentage > 100
      record.errors.add(:get_discount_percentage, :bogo_range)
    end
  end

  def validate_weight_threshold_promotion(record)
    if record.weight_threshold.blank? || record.weight_threshold <= 0
      record.errors.add(:weight_threshold, :weight_required)
    end
    
    if record.weight_discount_percentage.blank? || record.weight_discount_percentage < 0 || record.weight_discount_percentage > 100
      record.errors.add(:weight_discount_percentage, :weight_range)
    end
  end
end