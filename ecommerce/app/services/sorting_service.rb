class SortingService
  def initialize(model_class, sort_option = nil)
    @model_class = model_class
    @sort_option = sort_option || 'name_asc'
  end

  def sorted_collection
    case @sort_option
    when 'name_asc'
      name_ascending
    when 'name_desc'
      name_descending
    when 'products_asc'
      products_ascending
    when 'products_desc'
      products_descending
    else
      name_ascending # Default sorting
    end
  end

  private

  def name_ascending
    @model_class.includes(:items).order(:name)
  end

  def name_descending
    @model_class.includes(:items).order(name: :desc)
  end

  def products_ascending
    all_records = @model_class.includes(:items).to_a
    all_records.sort_by { |record| record.items.count }
  end

  def products_descending
    all_records = @model_class.includes(:items).to_a
    all_records.sort_by { |record| -record.items.count }
  end
end
