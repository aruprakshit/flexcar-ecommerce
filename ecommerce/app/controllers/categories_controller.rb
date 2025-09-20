class CategoriesController < ApplicationController
  def index
    @sort_option = params[:sort] || 'name_asc'
    @categories = SortingService.new(Category, @sort_option).sorted_collection
  end

  def show
    @category = Category.find(params[:id])
    @items = @category.items.includes(:brand, :category, :promotions).order(:name)
  end
end
