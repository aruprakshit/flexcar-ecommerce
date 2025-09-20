class CategoriesController < ApplicationController
  def index
    # Handle sorting
    case params[:sort]
    when 'name_asc'
      @categories = Category.includes(:items).order(:name)
    when 'name_desc'
      @categories = Category.includes(:items).order(name: :desc)
    when 'products_asc'
      # Sort by product count using SQL - load all categories first, then sort in Ruby
      all_categories = Category.includes(:items).to_a
      @categories = all_categories.sort_by { |category| category.items.count }
    when 'products_desc'
      # Sort by product count using SQL - load all categories first, then sort in Ruby
      all_categories = Category.includes(:items).to_a
      @categories = all_categories.sort_by { |category| -category.items.count }
    else
      @categories = Category.includes(:items).order(:name) # Default sorting
    end
    
    @sort_option = params[:sort] || 'name_asc'
  end

  def show
    @category = Category.find(params[:id])
    @items = @category.items.includes(:brand, :category, :promotions).order(:name)
  end
end
