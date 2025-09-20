class FeaturedItemsService
  def initialize(limit: 4)
    @limit = limit
  end

  def call
    item_ids = collect_item_ids_with_promotions
    Item.where(id: item_ids.uniq)
        .includes(:promotions, :brand, :category)
        .limit(@limit)
  end

  private

  def collect_item_ids_with_promotions
    item_ids = []
    
    # Items with direct promotions
    item_ids.concat(items_with_direct_promotions)
    
    # Items from brands with active promotions
    item_ids.concat(items_from_brands_with_promotions)
    
    # Items from categories with active promotions
    item_ids.concat(items_from_categories_with_promotions)
    
    item_ids
  end

  def items_with_direct_promotions
    Item.joins(:promotions)
        .where(promotions: Promotion.active)
        .pluck(:id)
  end

  def items_from_brands_with_promotions
    Item.joins(brand: :promotions)
        .where(promotions: { promotionable_type: 'Brand' })
        .where('promotions.start_time <= ? AND (promotions.end_time IS NULL OR promotions.end_time >= ?)', Time.current, Time.current)
        .pluck(:id)
  end

  def items_from_categories_with_promotions
    Item.joins(category: :promotions)
        .where(promotions: { promotionable_type: 'Category' })
        .where('promotions.start_time <= ? AND (promotions.end_time IS NULL OR promotions.end_time >= ?)', Time.current, Time.current)
        .pluck(:id)
  end
end
