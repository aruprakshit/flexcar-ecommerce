class ItemFilterService
  def initialize(params = {})
    @params = params
    @items = Item.includes(:brand, :category, :promotions)
  end

  def call
    apply_filters
    apply_sorting
    paginate
  end

  private

  attr_reader :params, :items

  def apply_filters
    @items = items.where(category_id: params[:category_id]) if params[:category_id].present?
    @items = items.where(brand_id: params[:brand_id]) if params[:brand_id].present?
  end

  def apply_sorting
    case params[:sort]
    when 'price_asc'
      @items = items.order(:price)
    when 'price_desc'
      @items = items.order(price: :desc)
    when 'category'
      @items = items.joins(:category).order('categories.name')
    when 'brand'
      @items = items.joins(:brand).order('brands.name')
    else
      @items = items.order(:name)
    end
  end

  def paginate
    @items = items.page(params[:page]).per(12)
  end
end
