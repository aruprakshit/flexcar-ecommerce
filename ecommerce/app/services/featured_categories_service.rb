class FeaturedCategoriesService
  def initialize(limit: 5)
    @limit = limit
  end

  def call
    category_ids = []
    
    # Get categories with direct promotions
    category_ids.concat(categories_with_direct_promotions)
    
    # Get categories that have items with promotions
    category_ids.concat(categories_with_items_having_promotions)
    
    Category.where(id: category_ids.uniq).includes(:promotions).limit(@limit)
  end

  private

  def categories_with_direct_promotions
    Category.joins(:promotions)
            .merge(Promotion.active)
            .pluck(:id)
  end

  def categories_with_items_having_promotions
    Category.joins(items: :promotions)
            .merge(Promotion.active)
            .pluck(:id)
  end
end
