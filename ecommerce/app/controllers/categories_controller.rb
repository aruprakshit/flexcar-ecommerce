class CategoriesController < ApplicationController
  def index
    @sort_option = params[:sort] || 'name_asc'
    @categories = SortingService.new(Category, @sort_option).sorted_collection
  end

  def show
    @category = Category.find(params[:id])
    @sort_option = params[:sort] || 'name_asc'
    @items = ItemSortingService.new(@category.items, @sort_option).sorted_collection
  end
end
