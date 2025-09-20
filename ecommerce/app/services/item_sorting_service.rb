class ItemSortingService
  def initialize(collection, sort_option = nil)
    @collection = collection
    @sort_option = sort_option || 'name_asc'
  end

  def sorted_collection
    case @sort_option
    when 'name_asc'
      name_ascending
    when 'name_desc'
      name_descending
    when 'price_asc'
      price_ascending
    when 'price_desc'
      price_descending
    when 'brand_asc'
      brand_ascending
    when 'brand_desc'
      brand_descending
    else
      name_ascending # Default sorting
    end
  end

  private

  def items_with_associations
    @collection.includes(:brand, :category, :promotions)
  end

  def name_ascending
    items_with_associations.order(:name)
  end

  def name_descending
    items_with_associations.order(name: :desc)
  end

  def price_ascending
    items_with_associations.order(:price)
  end

  def price_descending
    items_with_associations.order(price: :desc)
  end

  def brand_ascending
    items_with_associations.joins(:brand).order('brands.name ASC')
  end

  def brand_descending
    items_with_associations.joins(:brand).order('brands.name DESC')
  end
end
